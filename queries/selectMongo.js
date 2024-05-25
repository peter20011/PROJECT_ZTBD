#1
db.person.find({})

#2
db.competitor_event.aggregate([
    { "$match": { "medal_id": { "$exists": true } } },
    { "$lookup": {
        "from": "person",
        "let": { "competitorId": "$competitor_id" },
        "pipeline": [
            { "$match": { "$expr": { "$eq": [ "$id", "$$competitorId" ] } } },
            { "$project": { "_id": 0, "full_name": 1, "gender": 1, "height": 1, "weight": 1 } }
        ],
        "as": "competitor_info"
    }},
    { "$lookup": {
        "from": "medal",
        "let": { "medalId": "$medal_id" },
        "pipeline": [
            { "$match": { "$expr": { "$eq": [ "$id", "$$medalId" ] } } },
            { "$project": { "_id": 0, "medal_name": 1 } }
        ],
        "as": "medal_info"
    }},
    { "$project": {
        "_id": 0,
        "competitor_id": 1,
        "competitor_info": { "$arrayElemAt": [ "$competitor_info", 0 ] },
        "medal_info": { "$arrayElemAt": [ "$medal_info", 0 ] },
        "event_id": 1
    }}
]).forEach(printjson);

#3
db.person_region.aggregate([
    {
      $lookup: {
        from: "noc_region",
        localField: "region_id",
        foreignField: "_id",
        as: "region_info"
      }
    },
    {
      $unwind: "$region_info"
    },
    {
      $group: {
        _id: "$region_info.region_name",
        total_players: { $sum: 1 }
      }
    },
    {
      $sort: { total_players: -1 }
    },
    {
      $project: {
        _id: 0,
        region_name: "$_id",
        total_players: 1
      }
    }
  ])

#4
db.person.find(
    { height: { $gt: 180 } },
    { full_name: 1, height: 1, _id: 0 }
  )

  
#5
db.games_competitor.aggregate([
    {
      \$lookup: {
        from: 'person',
        localField: 'person_id',
        foreignField: 'id',
        as: 'person'
      }
    },
    {
      \$lookup: {
        from: 'games',
        localField: 'games_id',
        foreignField: 'id',
        as: 'game'
      }
    },
    {
      \$match: {
        'person.gender': 'F',
        'game.games_year': { \$ne: null }
      }
    },
    {
      \$unwind: '\$person'
    },
    {
      \$unwind: '\$game'
    },
    {
      \$group: {
        _id: '\$game.games_year',
        average_weight: { \$avg: '\$person.weight' }
      }
    },
    {
      \$project: {
        games_year: '\$_id',
        average_weight: 1,
        _id: 0
      }
    }
  ]).pretty();
  
#6
db.person.aggregate([
    {
      \$lookup: {
        from: 'games_competitor',
        localField: 'id',
        foreignField: 'person_id',
        as: 'games_competitors'
      }
    },
    {
      \$lookup: {
        from: 'competitor_event',
        localField: 'games_competitors.id',
        foreignField: 'competitor_id',
        as: 'competitor_events'
      }
    },
    {
      \$lookup: {
        from: 'event',
        localField: 'competitor_events.event_id',
        foreignField: 'id',
        as: 'events'
      }
    },
    {
      \$lookup: {
        from: 'medal',
        localField: 'competitor_events.medal_id',
        foreignField: 'id',
        as: 'medals'
      }
    },
    {
      \$project: {
        full_name: 1,
        games_competitors: {
          \$filter: {
            input: "\$games_competitors",
            as: "gc",
            cond: {
              \$gt: [{ \$size: "\$\$gc" }, 0]
            }
          }
        },
        competitor_events: {
          \$filter: {
            input: "\$competitor_events",
            as: "ce",
            cond: {
              \$gt: [{ \$size: "\$\$ce" }, 0]
            }
          }
        },
        events: {
          \$filter: {
            input: "\$events",
            as: "e",
            cond: {
              \$and: [
                { \$eq: ["\$\$e.event_name", "Sailing Mixed Two Person Heavyweight Dinghy"] },
                { \$gt: [{ \$size: "\$\$e" }, 0] }
              ]
            }
          }
        },
        medals: {
          \$filter: {
            input: "\$medals",
            as: "m",
            cond: {
              \$and: [
                { \$ne: ["\$\$m.medal_name", "NA"] },
                { \$gt: [{ \$size: "\$\$m" }, 0] }
              ]
            }
          }
        }
      }
    },
    {
      \$match: {
        \$expr: {
          \$and: [
            { \$gt: [{ \$size: "\$games_competitors" }, 0] },
            { \$gt: [{ \$size: "\$competitor_events" }, 0] },
            { \$gt: [{ \$size: "\$events" }, 0] },
            { \$gt: [{ \$size: "\$medals" }, 0] }
          ]
        }
      }
    },
    {
      \$project: {
        full_name: 1,
        event_name: { \$arrayElemAt: ["\$events.event_name", 0] },
        medal_name: { \$arrayElemAt: ["\$medals.medal_name", 0] }
      }
    },
    {
      \$sort: { full_name: 1 }
    }
  ]).pretty();
  

#7
db.noc_region.aggregate([
    {
      \$match: { region_name: 'Poland' }
    },
    {
      \$lookup: {
        from: 'person_region',
        localField: 'id',
        foreignField: 'region_id',
        as: 'person_regions'
      }
    },
    {
      \$lookup: {
        from: 'person',
        localField: 'person_regions.person_id',
        foreignField: 'id',
        as: 'persons'
      }
    },
    {
      \$lookup: {
        from: 'games_competitor',
        localField: 'persons.id',
        foreignField: 'person_id',
        as: 'games_competitors'
      }
    },
    {
      \$lookup: {
        from: 'competitor_event',
        localField: 'games_competitors.id',
        foreignField: 'competitor_id',
        as: 'competitor_events'
      }
    },
    {
      \$lookup: {
        from: 'games',
        localField: 'games_competitors.games_id',
        foreignField: 'id',
        as: 'games'
      }
    },
    {
      \$lookup: {
        from: 'medal',
        localField: 'competitor_events.medal_id',
        foreignField: 'id',
        as: 'medals'
      }
    },
    {
      \$project: {
        person_regions: {
          \$filter: {
            input: "\$person_regions",
            as: "person_region",
            cond: {
              \$in: ["\$\$person_region.person_id", "\$persons.id"]
            }
          }
        },
        persons: {
          \$filter: {
            input: "\$persons",
            as: "person",
            cond: {
              \$in: ["\$\$person.id", "\$games_competitors.person_id"]
            }
          }
        },
        games_competitors: {
          \$filter: {
            input: "\$games_competitors",
            as: "games_competitor",
            cond: {
              \$in: ["\$\$games_competitor.id", "\$competitor_events.competitor_id"]
            }
          }
        },
        competitor_events: {
          \$filter: {
            input: "\$competitor_events",
            as: "competitor_event",
            cond: {
              \$in: ["\$\$competitor_event.id", "\$medals.medal_id"]
            }
          }
        },
        games: {
          \$filter: {
            input: "\$games",
            as: "game",
            cond: { \$eq: ["\$\$game.games_year", 2000] }
          }
        },
        medals: {
          \$filter: {
            input: "\$medals",
            as: "medal",
            cond: { \$ne: ["\$\$medal.medal_name", "NA"] }
          }
        }
      }
    },
    {
      \$project: {
        total_medals: { \$size: "\$medals" }
      }
    },
    {
      \$group: {
        _id: null,
        total_medals: { \$sum: "\$total_medals" }
      }
    },
    {
      \$project: {
        total_medals: 1,
        _id: 0
      }
    }
  ]).pretty();
  