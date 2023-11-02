import vim
import os
import argparse
from filecmp import dircmp
from os.path import getsize
import sys
changed_files = {}
deleted_files = {}
added_files = {}
class DiffDir:
  def diff_file_size(self, file1, file2):
    return getsize(file2) - getsize(file1)
  
  def diff_report(self):
    for k, v in deleted_files.items():
      print(k, v)
  
    for k, v in added_files.items():
      print(k, v)
  
    for k, v in changed_files.items():
      print(k, v)
  
  def compare_dir(self, dir):
    for changed_file in dir.diff_files:
      file1 = "{0}/{1}".format(dir.left, changed_file)
      file2 = "{0}/{1}".format(dir.right, changed_file)
      changed_files[ file2 ] = self.diff_file_size(file1, file2)
  
    for deleted_file in dir.left_only:
      file1 = "{0}/{1}".format(dir.right, deleted_file)
      deleted_files[ file1 ] = "DELETED!"
  
    for added_file in dir.right_only:
      file1 = "{0}/{1}".format(dir.right, added_file)
      added_files[ file1 ] = "ADDED!"
  
    for sub_dir in dir.subdirs.values():
      self.compare_dir(sub_dir)
  
  def compdir(self, args):
    parser = argparse.ArgumentParser(description="Usage for diff_dir.py")
    dir = dircmp(args[0], args[1])
    self.compare_dir(dir)
    self.diff_report()
