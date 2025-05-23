// abstract class Pageable<T> {
//   int? curPage;
//   T? datas;
//   int? offset;
//   bool? over;
//   int? pageCount;
//   int? size;
//   int? total;
// }

abstract class Pageable {
  int? curPage;
  int? offset;
  bool? over;
  int? pageCount;
  int? size;
  int? total;
}