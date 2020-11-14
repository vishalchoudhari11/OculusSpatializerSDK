#include <iostream>
#include "OVR_Audio.h"
using namespace std;

void shutdownOvrAudio(ovrAudioContext Context)
{
   ovrAudio_DestroyContext(Context);
   ovrAudio_Shutdown();
}


int main(){
	cout << "My neighbours are noisy!" << endl;

	ovrAudioContext context;
	shutdownOvrAudio(context);

   	return 0;

}