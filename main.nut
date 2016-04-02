require("towns.nut");
require("town.nut");

import("util.superlib", "SuperLib", 38);
Helper <- SuperLib.Helper;

class VillagesIsVillages extends GSController
{
  data_loaded = false;
  towns = [];

  constructor()
  {
  }
}

function VillagesIsVillages::Start()
{
  GSLog.Info("Villages Is Villages started");

  if(!data_loaded)
  {
    towns = Towns();
    towns.Initialise();
  }

  while (true) {
    // Sleep 10 ticks between each loop
    this.Sleep(10);

    towns.ProcessNextTown();

    // Process any events which happened while we were sleeping
    while(GSEventController.IsEventWaiting())
    {
      local event = GSEventController.GetNextEvent();
      if(event != null && event.GetEventType() == GSEvent.ET_TOWN_FOUNDED)
      {
        local townEvent = GSEventTownFounded.Convert(event);
        GSLog.Info("New town founded");
        towns.AddTown(townEvent.GetTownID());
      }
    }
  }
}

function VillagesIsVillages::Save()
{
  local townData = [];

  foreach(t in towns.GetTownList())
  {
    townData.append({ id = t.GetId(), max_population = t.GetMaxPopulation() });
  }

  GSLog.Info("Saved town data");

  return { towns = townData };
}

function VillagesIsVillages::Load(version, data)
{
  local townData = [];

  if(data.rawin("towns")) {
    townData = data.rawget("towns");
    towns = Towns();
    towns.InitialiseWithData(townData);

    GSLog.Info("Loaded town data");

    data_loaded = true;
  }
}