#!/bin/bash

# remap space bar key to right option key on MacBook Pro
# I created this as a quick fix when the spacebar fell
# off my MacBook Pro.
# You can change the values in this simple command below
# to change any key into any other key.
# See also here:
# https://developer.apple.com/library/archive/technotes/tn2450/_index.html

hidutil property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x7000000E6,
      "HIDKeyboardModifierMappingDst":0x70000002C}]
}'


