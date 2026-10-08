class OfficialLinks {
  OfficialLinks._();

  static final institutional = Uri.parse('https://dgi.gouv.cd/');
  static final edef = Uri.parse('https://edef.dgirdc.cd/');
  static final verification = Uri.parse(
    'https://dgi.gouv.cd/verifier-un-document-authentification-qr-n/',
  );
  static final communiques = Uri.parse('https://dgi.gouv.cd/communiques-officiels/');

  // Keep unvalidated portals unavailable rather than guessing their addresses.
  static const Uri? teledeclaration = null;
  static const Uri? eNif = null;
  static const Uri? immatriculation = null;
  static const Uri? iNifEmploye = null;
  static const Uri? iImpotEmploye = null;

  static const redirectNotice =
      'Vous allez être redirigé vers un service officiel de la DGI.';
  static const allowedHosts = {'dgi.gouv.cd', 'edef.dgirdc.cd'};

  static bool isAllowed(Uri uri) =>
      uri.scheme == 'https' &&
      allowedHosts.contains(uri.host.toLowerCase()) &&
      uri.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443);
}
