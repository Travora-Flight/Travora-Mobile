class ValidateCompanionRequest {
  final String ticketNumber;

  ValidateCompanionRequest({
    required this.ticketNumber,
  });

  Map<String, String> toFormFields() => {
        "TicketNumber": ticketNumber,
      };
}
