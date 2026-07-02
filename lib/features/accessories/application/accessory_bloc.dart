import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/accessory_repository.dart';

class AccessoryState extends Equatable {
  final List<Map<String, dynamic>> accessories;
  final Map<String, dynamic>? accessory;
  final bool isLoading;
  final String? error;

  const AccessoryState({
    this.accessories = const [],
    this.accessory,
    this.isLoading = false,
    this.error,
  });

  AccessoryState copyWith({
    List<Map<String, dynamic>>? accessories,
    Map<String, dynamic>? accessory,
    bool? isLoading,
    String? error,
    bool clearAccessory = false,
  }) =>
      AccessoryState(
        accessories: accessories ?? this.accessories,
        accessory: clearAccessory ? null : (accessory ?? this.accessory),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [accessories, accessory, isLoading, error];
}

class LoadAccessoriesEvent {
  final String? search;
  LoadAccessoriesEvent({this.search});
}

class LoadAccessoryDetailEvent {
  final int id;
  LoadAccessoryDetailEvent(this.id);
}

class CreateAccessoryEvent {
  final Map<String, dynamic> data;
  CreateAccessoryEvent(this.data);
}

class UpdateAccessoryEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateAccessoryEvent(this.id, this.data);
}

class DeleteAccessoryEvent {
  final int id;
  DeleteAccessoryEvent(this.id);
}

class AccessoryBloc extends Bloc<Object, AccessoryState> {
  final AccessoryRepository _repo;
  AccessoryBloc(this._repo) : super(const AccessoryState()) {
    on<LoadAccessoriesEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final items = await _repo.getAll(search: e.search);
        emit(state.copyWith(isLoading: false, accessories: items));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadAccessoryDetailEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final item = await _repo.getById(e.id);
        emit(state.copyWith(isLoading: false, accessory: item));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<CreateAccessoryEvent>((e, emit) async {
      try {
        await _repo.create(e.data);
        final items = await _repo.getAll();
        emit(state.copyWith(accessories: items));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<UpdateAccessoryEvent>((e, emit) async {
      try {
        await _repo.update(e.id, e.data);
        final items = await _repo.getAll();
        emit(state.copyWith(accessories: items));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<DeleteAccessoryEvent>((e, emit) async {
      try {
        await _repo.delete(e.id);
        final items = await _repo.getAll();
        emit(state.copyWith(accessories: items));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
