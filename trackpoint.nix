{config, pkgs, ...}:
{
  services.xserver.inputClassSections = [
  ''
    Identifier      "Trackpoint Wheel Emulation"
    MatchProduct    "TPPS/2 IBM TrackPoint"
    Option          "EmulateWheel"          "on"
    Option          "EmulateWheelButton"    "2"
    Option          "Emulate3Buttons"       "false"
    Option          "EmulateWheelTimeout"     "200"
    Option          "EmulateWheelInertia"     "7"
    Option          "XAxisMapping"            "6 7"
    Option          "YAxisMapping"            "4 5"
    Option          "AccelerationProfile"     "3"
    Option          "AccelerationNumerator"   "55"
    Option          "AccelerationDenominator" "10"
    Option          "ConstantDeceleration"    "3"
  ''
];
}
