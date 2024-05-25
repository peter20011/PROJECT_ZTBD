db.competitor_event.updateMany(
  {
      "region_name": "Poland"
  },
  {
      \$set: { medal_id: db.medal.findOne({ medal_name: "Gold" }).id }
  }
);


db.person.updateMany(
  {},
  { \$inc: { weight: 5 } }
);

db.person.updateMany(
  {
      \$and: [
          { "region_name": "USA" },
          { "games_year": 1998 },
          { "medal_name": { \$ne: "Gold" } }
      ]
  },
  { \$inc: { height: 1 } }
);