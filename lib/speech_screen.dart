import 'package:chatgpt/api_service.dart';
import 'package:chatgpt/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

class SpeechScreen extends StatefulWidget {
  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  // const SpeechScreen({Key? key}) : super(key: key);
  var text = "Hold the button and start speaking";
  final List<ChatMessage> messages = []; 
  SpeechToText speechToText = SpeechToText();
  TextEditingController controller = TextEditingController();
  var scrollController = ScrollController();
  scrollMethod(){
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  var isListening = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 55.0,
        animate: isListening,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: Duration(seconds: 2),
        repeatPauseDuration: Duration(milliseconds: 100),
        showTwoGlows: true,
        repeat: true,
        glowColor: Colors.lightBlueAccent,
        child: GestureDetector(
          onTapDown: (details) async{
            print('tap down');
            Vibration.vibrate(duration: 50, amplitude: 2);
            // AudioPlayer audioPlayer = AudioPlayer();
            // AssetSource source = AssetSource('asset/note1.wav');
            // audioPlayer.play(source);
            if(!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(
                      onResult: (result) {
                        text = result.recognizedWords;
                      }
                  );
                });
              }
            }
          },
          onTapUp: (details) async{
            print('tap up');
            setState(() {
              isListening = false;
            });
            await speechToText.stop();
            if(text.isNotEmpty && text!= 'Hold the button and start speaking'){
              setState(() {
                messages.add(ChatMessage(text: text, type: ChatMessageType.user));
              });
              var msg = await ApiService.sendMessage(text);
              msg = msg.trim();
              setState(() {
                messages.add(ChatMessage(text: msg, type: ChatMessageType.bot));
              });
              
              Future.delayed(Duration(milliseconds: 500),(){
                TextToSpeech.speak(msg);
              });
            }
            else{
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Failed to process. Try again!')));
            }
          },
          child: CircleAvatar(
            radius: 35,
            child: Icon(Icons.mic),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            setState(() {
              messages.clear();
            });

          },
          icon: Icon(Icons.sort_rounded),
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text('Chat GPT'),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text,style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500
              ),),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context,index){
                            var chat = messages[index];
                            return chatBubble(
                              chattext: chat.text,
                              type: chat.type,
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        margin: EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async{
                                text = controller.text;
                                text = text.trim();
                                setState(() {
                                  messages.add(ChatMessage(text: text, type: ChatMessageType.user));
                                });
                                controller.clear();
                                var msg = await ApiService.sendMessage(text);
                                msg = msg.trim();
                                setState(() {
                                  messages.add(ChatMessage(text: msg, type: ChatMessageType.bot));
                                });

                              },
                              icon: Icon(Icons.send),
                            ),
                            hintText: 'Enter message.',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80,),
              // SizedBox(height: 97,),
              Text('Developed By Jafar Jalali',style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
              ),),
            ],
          ),
      ),
    );
  }
  Widget chatBubble({required chattext, required type}){
    bool check = false;
    if(type == ChatMessageType.bot){
      check = true;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: check?Image.asset('asset/bot1.png'):Icon(Icons.person),
        ),
        SizedBox(width: 12,),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 8),
            decoration:  BoxDecoration(
                color: check?Colors.lightBlueAccent:Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12)
                )
            ),
            child: Text(
              '$chattext',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class TextToSpeech{
  static FlutterTts tts = FlutterTts();


  static initTTS(){
    tts.setLanguage('hi-IN');
  }
  static speak(String text) async{
    await tts.awaitSpeakCompletion(true);
    tts.speak(text);
  }

}


