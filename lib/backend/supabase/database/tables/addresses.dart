import '../database.dart';

class AddressesTable extends SupabaseTable<AddressesRow> {
  @override
  String get tableName => 'addresses';

  @override
  AddressesRow createRow(Map<String, dynamic> data) => AddressesRow(data);
}

class AddressesRow extends SupabaseDataRow {
  AddressesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AddressesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get alias => getField<String>('alias')!;
  set alias(String value) => setField<String>('alias', value);

  String get address => getField<String>('address')!;
  set address(String value) => setField<String>('address', value);

  String get houseNumber => getField<String>('houseNumber')!;
  set houseNumber(String value) => setField<String>('houseNumber', value);

  String get zipCode => getField<String>('zipCode')!;
  set zipCode(String value) => setField<String>('zipCode', value);

  String get neighborhood => getField<String>('neighborhood')!;
  set neighborhood(String value) => setField<String>('neighborhood', value);

  String get city => getField<String>('city')!;
  set city(String value) => setField<String>('city', value);

  String get uuid => getField<String>('uuid')!;
  set uuid(String value) => setField<String>('uuid', value);
}
