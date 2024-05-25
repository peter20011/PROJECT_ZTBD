var deleteNRecords = function(n) {
    for (var i = 1; i <= n; i++) {
      db.person.deleteOne({ id: i });
    }
  };

  deleteNRecords(100);
