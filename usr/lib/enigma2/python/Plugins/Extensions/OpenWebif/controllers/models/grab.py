# -*- coding: utf-8 -*-

##########################################################################
# OpenWebif: grab
##########################################################################
# Copyright (C) 2011 - 2020 E2OpenPlugins
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
##########################################################################

from enigma import eConsoleAppContainer
from ServiceReference import ServiceReference
from Components.config import config
from Screens.InfoBar import InfoBar
from twisted.web import resource, server
from enigma import eDBoxLCD
import time, os
from Plugins.Extensions.OpenWebif.controllers.utilities import getUrlArg

GRAB_PATH = '/usr/bin/grab'

class grabScreenshot(resource.Resource):
	def __init__(self,session, path = ""):
		resource.Resource.__init__(self)
		self.session = session
		self.container = eConsoleAppContainer()
		self.appClosed_conn = self.container.appClosed.connect(self.grabFinished)

	def render(self, request):
		self.request = request

		mode = None
		graboptions = [GRAB_PATH]

		self.fileformat = getUrlArg(request, "format", "jpg")
		if self.fileformat == "jpg":
			graboptions.append("-j")
			graboptions.append("95")
		elif self.fileformat == "png":
			graboptions.append("-p")
		elif self.fileformat != "bmp":
			self.fileformat = "bmp"

		size = getUrlArg(request, "r")
		if size != None:
			graboptions.append("-r")
			graboptions.append("%d" % int(size))

		mode = getUrlArg(request, "mode")
		if mode != None:
			if mode == "osd":
				graboptions.append("-o")
			elif mode == "video":
				graboptions.append("-v")
			elif mode == "pip":
				graboptions.append("-v")
				if InfoBar.instance.session.pipshown:
					graboptions.append("-i 1")
			elif mode == "lcd":
				eDBoxLCD.getInstance().dumpLCD()
				self.fileformat = "png"
				command = "cat /tmp/lcdshot.%s" % self.fileformat

		if mode == "lcd":
			if self.container.execute(command):
				raise Exception("failed to execute: ", command)
			self.sref = 'lcdshot'
		else:
			self.container.execute(GRAB_PATH, *graboptions)
			try:
				if mode == "pip" and InfoBar.instance.session.pipshown:
					ref = InfoBar.instance.session.pip.getCurrentService().toString()
				else:
					ref = session.nav.getCurrentlyPlayingServiceReference().toString()
				self.sref = '_'.join(ref.split(':', 10)[:10])
				if config.OpenWebif.webcache.screenshotchannelname.value:
					self.sref = ServiceReference(ref).getServiceName()
			except:  # nosec # noqa: E722
				self.sref = 'screenshot'

		self.sref = self.sref + '_' + time.strftime("%Y%m%d%H%M%S", time.localtime(time.time()))
		self.filepath = "/tmp/screenshot." + self.fileformat
		graboptions.append(self.filepath)
		self.container.execute(GRAB_PATH, *graboptions)
		return server.NOT_DONE_YET

	def grabData(self, data):
		print("[W] grab: %s" & data)

	def grabFinished(self, retval = None):
		fileformat = self.fileformat
		try:
			fd = open(self.filepath)
			data = fd.read()
			fd.close()
			self.request.setHeader('Content-Disposition', 'inline; filename=%s.%s;' % (self.sref,self.fileformat))
			self.request.setHeader('Content-Type', 'image/%s' % fileformat.replace("jpg", "jpeg"))
			self.request.write(data)
		except Exception, error:
			self.request.write("Error creating screenshot:\n %s" % error)
		try:
			self.request.finish()
		except RuntimeError, error:
			print("[OpenWebif] grabFinished error: %s" % error)
		del self.request
		del self.filepath
