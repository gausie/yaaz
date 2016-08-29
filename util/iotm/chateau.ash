import "util/print.ash";
import "util/progress.ash";
import "util/util.ash";

boolean can_chateau()
{
  return to_boolean(get_property("chateauAvailable"));
}

boolean can_chateau_fight()
{
  if (to_boolean(get_property("_chateauMonsterFought")))
    return false;
  return true;
}

monster chateau_monster()
{
  return to_monster(get_property("chateauMonster"));
}

void chateau()
{

  if (!can_chateau())
  {
    return;
  }

  if (!to_boolean(get_property("_chateauDeskHarvested")))
  {
    log("Collecting items from the " + wrap("Chateau Mantegna", COLOR_LOCATION) + " desk.");
    visit_url("place.php?whichplace=chateau&action=chateau_desk2");
  }

  if (chateau_monster() == $monster[writing desk] && to_int(get_property("writingDesksDefeated")) < 5)
  {
    log("It looks like you're using the " + wrap("Chateau", COLOR_LOCATION) + " to do the " + wrap($monster[writing desk]) + " trick. Setting things up to accommodate this.");
    progress(to_int(get_property("writingDesksDefeated")), 5, "writing desks defeated");
    if (!list_contains(setting("digitize_list"), $monster[writing desk]))
    {
      string new_list = list_add(setting("digitize_list"), $monster[writing desk]);
      save_setting("digitize_list", new_list);
    }
    if (can_chateau_fight() && expected_damage($monster[writing desk]) < (my_hp() / 2))
    {
      log("Looks like we can fight one right now, so going to do that.");
      maximize();
      string temp = visit_url('place.php?whichplace=chateau&action=chateau_painting');
      run_combat();
    }
  }


}

void main()
{
  log("Doing default actions with the " + wrap("Chateau Mantegna", COLOR_LOCATION) + ".");
  chateau();
}
