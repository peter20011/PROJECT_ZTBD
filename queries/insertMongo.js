var insertRecordsCustom = function(numRecords) {
  var bulkRecords = [];
  for (var i = 0; i < numRecords; i++) {
    bulkRecords.push({
      full_name: "John Doe",
      gender: "Male",
      height: 180,
      weight: 75
    });
  }
  db.person.insertMany(bulkRecords);
};

insertRecordsCustom(100000);
