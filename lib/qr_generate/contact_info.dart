class ContactInfo {
  String? name;
  String? phone;
  String? email;
  String? organization;

  ContactInfo({this.name, this.phone, this.email, this.organization});

  String toVCard() {
    // Extract names and format accordingly
    final nameParts = name?.split(' ') ?? [];
    final lastName = nameParts.length > 1 ? nameParts[1] : '';
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';

    return '''
BEGIN:VCARD
VERSION:3.0
N:${lastName};${firstName}
FN:$name
ORG:$organization
EMAIL;TYPE=INTERNET:$email
TEL;TYPE=voice,cell,pref:$phone
END:VCARD
    ''';
  }
}
