class PasswordBody {
  late String email;
  late String oldPassword;
  late String newPassword;
  late String userId;

  PasswordBody({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
    required this.userId
  });

}