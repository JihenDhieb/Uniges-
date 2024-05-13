import 'dart:convert';

Employee employeeFromJson(String str) => Employee.fromJson(json.decode(str));

String employeeToJson(Employee data) => json.encode(data.toJson());

class Employee {
  Employee({
    this.persoNom,
    this.persoMotDePasse,
  });

  String? persoNom;
  String? persoMotDePasse;

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        persoNom: json["Perso_Nom"],
        persoMotDePasse: json["Perso_MotDePasse"],
      );

  Map<String, dynamic> toJson() => {
        "Perso_Nom": persoNom,
        "Perso_MotDePasse": persoMotDePasse,
      };
}
