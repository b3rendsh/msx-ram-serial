�B�  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  *��RS��R *��? ��íh	�  � Fossil driver not installed
$��	� ������͆���
$��� ��� � �?����!� ���]Ϳ�b��b2��~ �:�b�#�~ � ʨ�,�!Ϳ�b��b2��~	G:���:�go��:� �w�w�w�w�~ �,¨�#Ϳ�b� ʨ�@�b2��~	G:���K:�g�è�:� �wè�wèk�͆èUsage:
FMODE <channel>:<speed>,<protocol>

channel  = 0..1
speed    = 0..12
protocol = 0..63

Examples:
0:8,7  set channel 0 to 38400 / 8N1
1:9,46 set channel 1 to 57600 / 7E2
0:7    set channel 0 to 19200 baud

0:,46  set channel 0 to 7E2 protocol

Use FDINFO to display current config.$Invalid option, type FMODE for help.
$    �~ �08�:0y�؁��O�~ �0��O�#�y���~ ��� ��#�