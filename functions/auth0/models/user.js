class User {
  constructor(
      userId,
      email,
      firstName,
      lastName,
      address,
      address2,
      city,
      state,
      zip,
      phone,
      metadata
  ) {
    this.userId = userId,
    this.email = email,
    this.firstName = firstName,
    this.lastName = lastName,
    this.address = address,
    this.address2 = address2,
    this.city = city,
    this.state = state,
    this.zip = zip,
    this.phone = phone,
    this.metadata = metadata;
  }
}

module.exports = {User};
