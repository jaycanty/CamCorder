### To run

- `git clone https://github.com/jaycanty/CamCorder.git`
- `cd CamCorder`
- `open CamCorder.xcworkspace`
- **run**

> Pods are checked in.  
> App uses a free firebase account, which is limited and shuts off (Not yet, which concerns me).

### CamCorder

Let's you record videos and upload to Firebase. Displays uploaded videos and can be viewed.

#### Architecture

- AVFoundation records the video and writes it to disk.
- Once recording has stopped, the file is added to an operation queue. This enables videos to be recorded one after another.
- Once uploaded, the file is deleted from disk
- The uploaded videos are displayed in a collection view as well as videos that are currently uploading. The collection datasource combines firebase data with operation queue data.
- Press on a cell and the user can view the video in an  AVPlayerController.

#### Challenges

- Video lends it's self well to concurrency, which can easily get out of hand. I am not proud of the VideoUploader Operation.
- My original goal was to kick off uploading to a server while recording. I got very close on the client, I was able to observe the file that was being written to by AVCaptureMovieFileOutput and have proven that I can read it while it grows. I tried to use Firebases's uploadFile, and kicked it off after the Movie file grew to a certain size, but Firebase only reads it once and sends what it sees.  The next solution would have been to upload chunks at a time and reassemble, that task outran the scope.

#### Todo's

- Error handling
- Memory profiling
- Refactor VideoUploader
- Upload while recording! 
- Compression!  

  