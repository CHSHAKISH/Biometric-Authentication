import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';

void main(){
  runApp(BiometricApp());
}

class BiometricApp extends StatelessWidget {
  const BiometricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric App',
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final String pin = '1234';
  final TextEditingController controller = TextEditingController();

  bool biometricAvailability = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try{
      bool available = await auth.canCheckBiometrics;
      setState(() {
        biometricAvailability = available;
      });
    }
    catch(e){
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text('Enter Pin', style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),),
            SizedBox(height: 10,),
            Text('Please enter your 4-digit pin to continue', style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),),
            SizedBox(height: 32,),
            Pinput(
              controller: controller,
              length: 4,
              onCompleted: _onCompleted,
              obscureText: true,
              autofocus: true,
            ),
            Spacer(),
            if(biometricAvailability)
              Column(
                children: [
                  Text('Or', style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),),
                  SizedBox(height: 10,),
                  InkWell(
                    onTap: isLoading ? null: () => _biometricAuthentication(),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue[200]!)
                      ),
                      child: isLoading ? CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ) : Icon(Icons.fingerprint, size: 32, color: Colors.blue[600],)
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('use biometric', style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 18,
                  ),),
                  SizedBox(height: 20,),
                ],
              )

          ],
        ),
      )),
    );
  }

  void _onCompleted(String enteredPin){
    if(enteredPin == pin){
      _navigateToSecondScreen();
    }
    else{
      print('PIN is wrong');
      controller.clear();
    }
  }

  void _navigateToSecondScreen(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
      return secondScreen();
    }));
  }

  Future<void> _biometricAuthentication() async {
    if(!biometricAvailability){
      return;
    }
    setState(() {
      isLoading = true;
    });

    try{
      bool authenticate = await auth.authenticate(localizedReason: 'Text for localization reason',
      options: AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,

      ));

      if(authenticate){
        _navigateToSecondScreen();
      }
    }
    catch(e){
      print(e.toString());
    }
    finally{
      setState(() {
        isLoading = false;
      });
    }
  }
}

class secondScreen extends StatelessWidget {
  const secondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text('Logged In!', style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
      ),
    );
  }
}




