import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/services/fund_service.dart';

import '../../models/fund.dart';

class ManageFundBloc extends Bloc<ManageFundEvent, ManageFundState> {
  ManageFundBloc(FundService fundService) : super(ManageFundState()) {
    fundService.getFunds().then((funds) {
      add(ManageFundLoadedEvent(funds));
    });
    
    on<ManageFundLoadedEvent>((event, emit) => emit(state.copyWith(funds: event.funds)));

    on<ManageFundActionSelectedEvent>((event, emit) {
      final isQueryParameter = event.queryParameter;
      if (isQueryParameter) {
        state.urlEditController.text += state.urlEditController.text.contains('?') ? '&' : '?';
      }

      state.urlEditController.text += event.action;

      if (!isQueryParameter) {
        state.urlEditController.text += '/';
      }
    });

    on<ManageFundUrlClearEvent>((event, emit) {
      state.urlEditController.text = '';
      emit(state.copyWith(response: ''));
    });

    on<ManageFundSubmitEvent>((event, emit) {
      final url = state.urlEditController.text;
      state.histories.insert(0, url);
      emit(state.copyWith(histories: state.histories));
      fundService.submitRequest(state.urlEditController.text, event.isDelete)
          .then((response) => add(ManageFundSubmittedEvent(response)));
    });

    on<ManageFundSubmittedEvent>((event, emit) {
      emit(state.copyWith(response: event.response));
      fundService.getFunds().then((funds) {
        add(ManageFundLoadedEvent(funds));
      });
    });
  }
}

@immutable
sealed class ManageFundEvent {}

class ManageFundLoadedEvent extends ManageFundEvent {
  final List<Fund> funds;
  ManageFundLoadedEvent(this.funds);
}

class ManageFundActionSelectedEvent extends ManageFundEvent {
  final String action;
  final bool queryParameter;
  ManageFundActionSelectedEvent(this.action, this.queryParameter);
}


class ManageFundSubmittedEvent extends ManageFundEvent {
  final String response;
  ManageFundSubmittedEvent(this.response);
}

class ManageFundUrlClearEvent extends ManageFundEvent {}
class ManageFundSubmitEvent extends ManageFundEvent {
  final bool isDelete;
  ManageFundSubmitEvent({required this.isDelete});
}

class ManageFundState {
  final List<Fund> funds;
  final TextEditingController urlEditController;
  final String response;
  final List<String> histories;

  ManageFundState(
      {List<Fund>? funds, TextEditingController? urlEditController, this.response = '', List<String>? histories})
      : funds = funds ?? [],
        urlEditController = urlEditController ?? TextEditingController(),
        histories = histories ?? [];

  ManageFundState copyWith({
    List<Fund>? funds,
    TextEditingController? urlEditController,
    String? response,
    List<String>? histories,
  }) {
    return ManageFundState(
      funds: funds ?? this.funds,
      urlEditController: urlEditController ?? this.urlEditController,
      response: response ?? this.response,
      histories: histories ?? this.histories,
    );
  }
}
