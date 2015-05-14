import numpy as np
import pylab as pl

import glob
import serial
import subprocess
import sys
import threading
import time

from cv2 import VideoCapture, VideoWriter
from cv2.cv import CV_FOURCC

import hapticsstb_rt

# Constants for plotting
PLOT_FT = 1
PLOT_M40V = 2
PLOT_ACC = 3
PLOT_POS = 4

# Error for STB class
class EmptyPacketError(Exception):
    pass

# Class for the Haptics STB. Manages initialization, stop, start and reading raw serial packets
class STB(object):

    def __init__(self, sample_rate, device='', video=''):

        if device == '':
            if sys.platform == 'darwin':
                devices = glob.glob('/dev/tty.usbmodem*')
            elif sys.platform == 'linux2':
                devices = glob.glob('/dev/ttyACM*')
            else:
                print "Unrecognized Platform!"

            for dev in devices:
                test_device = serial.Serial(dev, timeout=0.1)
                test_device.write('\x02')
                time.sleep(0.05)
                test_device.flushInput()
                test_device.write('\x03')

                dev_id = test_device.read(200)[-1]

                if dev_id == '\x01':
                    self.device = test_device
                    break
            else:
                print 'STB not found! Check all cables!'
                sys.exit()
        else:
            self.device = serial.Serial(device)

        if sample_rate > 100:
            self.device.timeout = 0.05
        else:
            self.device.timeout = 0.5

        if video:
            self.video = True
            err = subprocess.call(['v4l2-ctl', '-i 4'])
            if err == 1:
                print "VIDEO CAPTURE ERROR, CHECK CARD AND TRY AGAIN"
                sys.exit()

            cap = VideoCapture(-1)
            fourcc = CV_FOURCC(*'XVID')

            out = VideoWriter(video, fourcc, 29.970, (720, 480))
            self.video_thread = OpenCVThread(cap, out)

        else:
            self.video = False

        if sample_rate > 3000:
            print 'Sampling Rate too high!'
            raise ValueError

        self.update_rate(sample_rate)
        self.bias_vector = np.zeros(6, dtype=np.float64)
        self.frame = 0
        self.packet_old = 300
        self.pack = '\00'*31

        self.plot_objects = None
        self.plot_type = 0
        self.plot_data = None

    def update_rate(self, sample_rate):
        self.sample_rate = sample_rate
        high = (sample_rate&int('0xFF00', 16))>>8
        low = sample_rate&int('0x00FF', 16)
        self.sample_rate_bytes = chr(high)+chr(low)

    def bias(self):
        bias_hist = np.zeros((self.sample_rate/5, 6))
        self.start_sampling()
        for ii in range(0, self.sample_rate/5):
            bias_hist[ii, :] = self.read_M40V()

        self.stop_sampling()
        self.bias_vector = np.mean(bias_hist, axis=0)

    def start_sampling(self):
        self.device.write('\x01' + self.sample_rate_bytes)
        self.packet_old = 300

        if self.video:
            self.video_thread.start()

    def stop_sampling(self):
        self.device.write('\x02')
        self.device.flush()

        if self.video:
            self.video_thread.stop.set()

    def read_packet(self):
        pack = self.device.read(31)

        if pack == '' or len(pack) != 31:
            raise EmptyPacketError
        packet_new = ord(pack[30])

        if self.packet_old >= 256:
            self.packet_old = packet_new
        elif packet_new != (self.packet_old+1)%256:
            print 'MISSED PACKET', packet_new, self.packet_old

        self.packet_old = packet_new
        self.pack = pack
        return pack

    def read_data(self):
        self.pack = self.read_packet()
        return hapticsstb_rt.serial_data(self.pack, self.bias_vector)

    def read_m40(self):
        self.pack = self.read_packet()
        return hapticsstb_rt.serial_m40(self.pack, self.bias_vector)

    def get_m40(self):
        return hapticsstb_rt.serial_m40(self.pack, self.bias_vector)

    def read_m40v(self):
        self.pack = self.read_packet()
        return hapticsstb_rt.serial_m40v(self.pack)

    def get_m40v(self):
        return hapticsstb_rt.serial_m40v(self.pack)

    def read_acc(self):
        self.pack = self.read_packet()
        return hapticsstb_rt.serial_acc(self.pack)

    def get_acc(self):
        return hapticsstb_rt.serial_acc(self.pack)

    def plot_init(self, plot_type, plot_length):
        self.update_rate(500)
        line_length = self.sample_rate*plot_length
        self.plot_objects = plotting_setup(plot_type, self.line_length)
        self.plot_type = plot_type
        self.frame = 1

        if self.plot_type in [PLOT_FT, PLOT_M40V, PLOT_POS]:
            self.plot_data = np.zeros((line_length, 6))
        elif self.plot_type == PLOT_ACC:
            self.plot_data = np.zeros((line_length, 9))
        else:
            print "Unrecognized plotting type!"
            sys.exit()

    def plot_update(self):
        if self.plot_type in [PLOT_FT, PLOT_POS]:
            new_data = self.get_M40()
        elif self.plot_type == PLOT_M40V:
            new_data = self.get_M40V()
        elif self.plot_type == PLOT_ACC:
            new_data = self.get_ACC()

        self.plot_data = np.roll(self.plot_data, -1, axis=0)
        self.plot_data[-1, 0:] = new_data
        if self.frame % 50 == 0:
            hapticsstb_rt.plotting_updater(self.plot_type, self.plot_data, self.plot_objects)
            self.frame = 1
        else:
            self.frame += 1

    def close(self):
        self.stop_sampling()
        self.device.close()

class OpenCVThread(threading.Thread):
    def __init__(self, cap, out):
        threading.Thread.__init__(self)
        self.stop = threading.Event()
        self.out = out
        self.cap = cap

    def run(self):
        while not self.stop.is_set():
            ret, frame = self.cap.read()
            if ret == True:
                self.out.write(frame)

def plotting_setup(plot_type, line_length):

    pl.ion()

    if plot_type in [PLOT_FT, PLOT_M40V, PLOT_ACC]:
        start_time = -1*(line_length-1)/500.0
        times = np.linspace(start_time, 0, line_length)

    # Force/Torque Graphing
    if plot_type == PLOT_FT:

        (axF, axT) = pl.subplots(2, 1, sharex=True)

        axF.axis([start_time, 0, -5, 5])
        axF.grid()
        axT.axis([start_time, 0, -.5, .5])
        axT.grid()

        fx_line, = axF.plot(times, [0] * line_length, color='r')
        fy_line, = axF.plot(times, [0] * line_length, color='g')
        fz_line, = axF.plot(times, [0] * line_length, color='b')
        tx_line, = axT.plot(times, [0] * line_length, color='c')
        ty_line, = axT.plot(times, [0] * line_length, color='m')
        tz_line, = axT.plot(times, [0] * line_length, color='y')

        axF.legend([fx_line, fy_line, fz_line], ['FX', 'FY', 'FZ'])
        axT.legend([tx_line, ty_line, tz_line], ['TX', 'TY', 'TZ'])

        plot_objects = (fx_line, fy_line, fz_line, tx_line, ty_line, tz_line)

        pl.draw()

    # Mini40 Voltage Graphing
    elif plot_type == PLOT_M40V:

        pl.axis([start_time, 0, -2, 2])
        pl.grid()

        c0_line, = pl.plot(times, [0] * line_length, color='brown')
        c1_line, = pl.plot(times, [0] * line_length, color='yellow')
        c2_line, = pl.plot(times, [0] * line_length, color='green')
        c3_line, = pl.plot(times, [0] * line_length, color='blue')
        c4_line, = pl.plot(times, [0] * line_length, color='purple')
        c5_line, = pl.plot(times, [0] * line_length, color='gray')

        pl.legend([c0_line, c1_line, c2_line, c3_line, c4_line, c5_line], 
                  ['Channel 0', 'Channel 1', 'Channel 2', 'Channel 3', 'Channel 4', 'Channel 5'],
                  loc=2)

        plot_objects = (c0_line, c1_line, c2_line, c3_line, c4_line, c5_line)
        pl.draw()

    #Accelerometer Voltage Graphing
    elif plot_type == PLOT_ACC:

        (ax1, ax2, ax3) = pl.subplots(3, 1, sharex=True)

        ax1.axis([start_time, 0, -7, 7])
        ax2.axis([start_time, 0, -7, 7])
        ax3.axis([start_time, 0, -7, 7])
        ax1.grid()
        ax2.grid()
        ax3.grid()

        a1x_line, = ax1.plot(times, [0] * line_length, color='r')
        a1y_line, = ax1.plot(times, [0] * line_length, color='g')
        a1z_line, = ax1.plot(times, [0] * line_length, color='b')
        a2x_line, = ax2.plot(times, [0] * line_length, color='r')
        a2y_line, = ax2.plot(times, [0] * line_length, color='g')
        a2z_line, = ax2.plot(times, [0] * line_length, color='b')
        a3x_line, = ax3.plot(times, [0] * line_length, color='r')
        a3y_line, = ax3.plot(times, [0] * line_length, color='g')
        a3z_line, = ax3.plot(times, [0] * line_length, color='b')

        plot_objects = (a1x_line, a1y_line, a1z_line, a2x_line, a2y_line, a2z_line,
                        a3x_line, a3y_line, a3z_line)

        pl.draw()

    # 2D Position Plotting
    elif plot_type == 4:

        pl.axis([-.075, .075, -.075, .075])
        pl.grid()
        touch_point, = pl.plot(0, 0, marker="o", markersize=50)

        plot_objects = (touch_point,)
        pl.draw()

    else:
        print "INVALID GRAPHING MODE"
        return 0

    return plot_objects
