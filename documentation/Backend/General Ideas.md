Settings
- Scan/compress/upload frequency (or just manual)
- Compression ratio
- Upload over mobile data / foreign WiFi
- Include all folders by default
- Folder inclusion/exclusion list

General Flow
1. Scan for new images with the frequency set
	1. Potentially compress photos and have them waiting when upload isn't available
2. Upload raw photos to server, delete once verified

> Info injected into image metadata to link it to the original to allow the image to be moved between folders

Verification
1. Find all compressed replacement images on device and inspect metadata
2. Compare to images on server
	1. If compressed are missing, regenerate
	2. If image has been moved, move accordingly on server

