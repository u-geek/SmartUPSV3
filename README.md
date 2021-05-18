# Smart UPS V3

U-Geek Raspberry Pi Smart UPS V3

git clone https://github.com/u-geek/SmartUPSV3.git --depth 1

cd SmartUPSV3

sudo ./install.sh



               ┌────────────────────┤ UGEEK WORKSHOP ├────────────────────┐
               │ Select the appropriate options:                          │
               │                                                          │
               │                 1 UPS GPIO [ 18 ]                        │
               │                 2 LED Brightness [ 10% ]                 │
               │                 3 Poweoff power [ <5% ]                  │
               │                 4 Autorun [ enabled ]                    │
               │                 5 Safe shutdown [ enabled ]              │
               │                 6 Apply Settings                         │
               │                 7 Remove                                 │
               │                 8 Exit                                   │
               │                                                          │
               │                                                          │
               │                                                          │
               │                                                          │
               │                          <Ok>                            │
               │                                                          │
               └──────────────────────────────────────────────────────────┘


View Status:

sudo python status.py or sudo python status.py -t

View logs:

cat /var/log/smartups.log


