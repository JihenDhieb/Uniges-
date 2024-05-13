import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uniges/main.dart';
import 'package:uniges/model/Employee.dart';
import 'package:uniges/modules/home/register_page.dart';
import 'package:uniges/services/OtaUpdate.dart';
import 'package:uniges/services/company_service.dart';
import 'package:uniges/services/uniges_service.dart';

Employee? employee;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  GetStorage storage = GetStorage();
  bool _isPasswordVisible = false;
  bool isSavePassChecked = false;
  bool isLoggedIn = false;
  bool isPassSavedInDevice = false;
  bool isLoading = false;
  bool enableEditing = true;
  List<dynamic>? companies;
  String stats = "";
  var nameCompany;
  @override
  void initState() {
    companies = Company.getRegisteredCompanies();
    if (companies != null && companies!.length > 1) {
      nameCompany = companies![0]['name'];
      Company.setSelectedCompany(companies![0]['name']);
    }
    checkSavedPass();
    isLoggedIn = (employee != null);
    super.initState();
  }

  Future<void> checkSavedPass() async {
    try {
      String? savedPassword = storage.read('password_$nameCompany');
      String? savedUsername = storage.read('username_$nameCompany');
      if (savedUsername != null &&
          savedUsername.isNotEmpty &&
          savedPassword != null &&
          savedPassword.isNotEmpty) {
        setState(() {
          isPassSavedInDevice = true;
        });
        await checkDeviceLocalAuth();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkDeviceLocalAuth() async {
    String? savedPassword = storage.read('password_$nameCompany');
    String? savedUsername = storage.read('username_$nameCompany');

    if (savedUsername != null &&
        savedUsername.isNotEmpty &&
        savedPassword != null &&
        savedPassword.isNotEmpty) {
      // Check if biometrics is available and supported
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (isDeviceSupported) {
        // Authenticate with biometrics
        bool isAuthenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access your password',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        if (isAuthenticated) {
          _passwordController.text = savedPassword;
          _emailController.text = savedUsername;
          await login();
        } else {
          Fluttertoast.showToast(msg: "essayer à nouveau");
        }
      } else {
        Fluttertoast.showToast(msg: "dispositif non pris en charge");
      }
    } else {
      Fluttertoast.showToast(msg: "aucune donnée enregistrée sur l'appareil");
      return;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Image.asset(
                  'assets/icons/logo.png',
                  height: 60,
                  width: 60,
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Société',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      DropdownButton<String>(
                        hint: Text("societe"),
                        value: nameCompany,
                        onChanged: (String? selectedCompany) {
                          Company.setSelectedCompany(selectedCompany!);
                          nameCompany = selectedCompany;
                          setState(() {});
                        },
                        items: companies?.map<DropdownMenuItem<String>>(
                                (dynamic company) {
                              return DropdownMenuItem<String>(
                                value: company['name'],
                                child: Text(company['name']),
                              );
                            }).toList() ??
                            [],
                      ),
                      IconButton(
                          onPressed: () {
                            Get.to(() => CompanyRegistrationWidget());
                          },
                          icon: Icon(Icons.add))
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),
                const Text(
                  'connexion',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'UserName',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  onFieldSubmitted: (_) {
                    login();
                  },
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                //SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("enregistrer votre mot de passe"),
                    Checkbox(
                        checkColor: Colors.white,
                        value: isSavePassChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isSavePassChecked = value!;
                          });
                        }),
                  ],
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: login,
                  child: const Text(
                    'Se Connecter',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (isPassSavedInDevice)
                  IconButton(
                      onPressed: () {
                        checkDeviceLocalAuth();
                      },
                      icon: const Icon(
                        Icons.fingerprint_outlined,
                        color: Colors.red,
                        size: 60,
                      )),

                Text(
                  androidId,
                  textAlign: TextAlign.center,
                ),
                Text(
                  stats,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (_emailController.text == "" || _passwordController.text == "") return;
    setState(() {
      isLoading = true;
      isLoggedIn = false;
      enableEditing = false;
    });

    try {
      var isLoginSuccess = await UnigesService.login(
          _emailController.text, _passwordController.text);

      if (isLoginSuccess) {
        if (isSavePassChecked) {
          GetStorage storage = GetStorage();
          await storage.write(
              'password_$nameCompany', _passwordController.text);
          await storage.write('username_$nameCompany', _emailController.text);
        }
        employee = Employee(
            persoNom: _emailController.text,
            persoMotDePasse: _passwordController.text);
        isLoading = false;
        isLoggedIn = true;
        enableEditing = true;
        Get.toNamed("/menu");
      } else {
        String? savedUsername = storage.read('username_$nameCompany');
        String? savedPassword = storage.read('password_$nameCompany');

        if (savedUsername == _emailController.text &&
            savedPassword == _passwordController.text) {
          employee =
              Employee(persoNom: savedUsername, persoMotDePasse: savedPassword);
          isLoading = false;
          isLoggedIn = true;
          enableEditing = true;

          Fluttertoast.showToast(
            msg: "Mode hors ligne",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Get.toNamed("/menu");
        } else {
          Fluttertoast.showToast(
              msg:
                  "Veuillez vérifier le nom d'utilisateur et/ou le mot de passe !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: const Color.fromARGB(255, 231, 131, 131),
              textColor: Colors.white,
              fontSize: 16.0);
          isLoading = false;
          isLoggedIn = false;
          enableEditing = true;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Un problème de connexion est survenu !",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 231, 131, 131),
          textColor: Colors.white,
          fontSize: 16.0);
      isLoading = false;
      isLoggedIn = false;
      enableEditing = true;
    }
    setState(() {});
  }
}
