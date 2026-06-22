import '../../domain/investment_models.dart';

abstract class InvestmentState {}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentLoaded extends InvestmentState {
  final List<Investment> investments;
  final PortfolioSummary summary;

  InvestmentLoaded({required this.investments, required this.summary});
}

class InvestmentError extends InvestmentState {
  final String message;
  InvestmentError(this.message);
}

class InvestmentSubmitting extends InvestmentState {}

class InvestmentSubmitSuccess extends InvestmentState {
  final String message;
  InvestmentSubmitSuccess(this.message);
}
