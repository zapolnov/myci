import os

from conan import ConanFile, tools

class TestConan(ConanFile):
	settings = "os", "compiler", "build_type", "arch"

	def requirements(self):
		self.tool_requires(self.tested_reference_str)

	def test(self):
		self.run("myci-passed.sh", env="conanbuild") # env sets LD_LIBRARY_PATH etc. to find dependency libs
