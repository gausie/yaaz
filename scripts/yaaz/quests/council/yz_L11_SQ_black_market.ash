import "util/yz_main.ash";


familiar bird = $familiar[reassembled blackbird];
if (my_path() == "Bees Hate You")
  bird = $familiar[reconstituted crow];

boolean do_one_market_adv()
{
  if (creatable_amount($item[reassembled blackbird]) > 0)
  {
    log("Making a " + wrap($item[reassembled blackbird]) + " to help with exploration.");
    create(1, $item[reassembled blackbird]);
  }

  set_property("choiceAdventure923", 1);
  if (item_amount($item[beehive]) == 0)
  {
    set_property("choiceAdventure924", 3);
    set_property("choiceAdventure1018", 1);
    set_property("choiceAdventure1019", 1);
  } else {
    set_property("choiceAdventure924", 1);
  }

  string max = "items";
  if (item_amount($item[beehive]) > 0)
  {
    max = "combat, 0.2 items";
  }

  if (!have(bird.hatchling) && can_adventure_with_familiar(bird))
  {
    maximize(max, $item[blackberry galoshes], bird);
  } else {
    maximize(max, $item[blackberry galoshes]);
  }

  int bee = item_amount($item[beehive]);
  boolean b = yz_adventure($location[the black forest]);
  if (bee < item_amount($item[beehive]))
    log(wrap($item[beehive]) + " found!");
  return b;
}

boolean market_loop()
{
  int status = quest_status("questL11Black");
  maybe_pull($item[blackberry galoshes]);

  switch (status)
  {
    case UNSTARTED:
      if (my_level() < 11)
      {
        error("You can't attempt this quest until you're level 11. Level up!");
        abort();
      }
      log("Going to the council to pick up the quest.");
      council();
      return true;
    case STARTED:
    case 1:
      return do_one_market_adv();
    case 2:
      if (item_amount($item[forged identification documents]) == 0)
      {
        if (my_path() == "Way of the Surprising Fist")
        {
          visit_url("shop.php?action=fightbmguy&whichshop=blackmarket");
          run_combat('yz_consult');
        } else {
          buy(1, $item[forged identification documents]);
        }
      } else {
        if (to_int(get_property("lastDesertUnlock")) < my_ascensions())
        {
          info("Can't get your father's diary until you access the desert.");
          return false;
        }
        switch (my_primestat())
        {
          case $stat[muscle]:
            set_property("choiceAdventure793", 1);
            break;
          case $stat[mysticality]:
            set_property("choiceAdventure793", 2);
            break;
          case $stat[moxie]:
            set_property("choiceAdventure793", 3);
            break;
        }
        yz_adventure($location[The Shore\, Inc. Travel Agency]);
      }
      return true;
    default:
      return false;
  }
}

boolean L11_SQ_black_market()
{

  if (quest_status("questL11Black") == FINISHED)
    return false;

  if (my_level() < 11)
    return false;

  return market_loop();
}

void main()
{
  while (L11_SQ_black_market());
}
