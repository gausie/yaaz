import "util/base/yz_print.ash";
import "util/base/yz_effects.ash";
import "util/base/yz_inventory.ash";
import "util/base/yz_maximize.ash";
import "util/base/yz_util.ash";
import "util/yz_heart.ash";
import "util/base/yz_consume.ash";
import "util/prep/yz_sell.ash";
import "util/prep/yz_buy.ash";
import "util/prep/yz_buy_skills.ash";
import "util/prep/yz_clan.ash";
import "util/prep/yz_make.ash";
import "util/prep/yz_pulverize.ash";
import "util/prep/yz_use.ash";
import "util/prep/yz_closet.ash";
import "util/prep/classes/yz_prep_accordionthief.ash";
import "util/prep/classes/yz_prep_discobandit.ash";
import "util/prep/classes/yz_prep_pastamancer.ash";
import "util/prep/classes/yz_prep_sauceror.ash";
import "util/prep/classes/yz_prep_sealclubber.ash";
import "util/prep/classes/yz_prep_turtletamer.ash";
import "util/prep/paths/yz_prep_lta.ash";
import "special/locations/yz_vip_floundry.ash";
import "special/items/yz_deck.ash";
import "special/skills/yz_flavour_of_magic.ash";

import <zlib.ash>


void prep_fishing(location loc)
{
  if (is_fishing_hole(loc))
  {
    log("This location (" + wrap(loc) + ") may have floundry fish in it.");
    effect_maintain($effect[baited hook]);
  }
}

void cast_things(location loc)
{

  // Things we may as well use. Low cost and sometimes helpful:
  effect_maintain($effect[bloodstain-resistant]);

  effect_maintain($effect[Neuroplastici Tea]);
  effect_maintain($effect[flexibili Tea]);
  effect_maintain($effect[Physicali Tea]);

  while (have_skill($skill[ancestral recall]) && to_int(get_property("_ancestralRecallCasts")) < 10 && have($item[blue mana]))
  {
    log("Casting " + wrap($skill[ancestral recall]) + " to get us a few more adventures.");
    use_skill(1, $skill[ancestral recall]);
  }


  // Way of the Surprising Fist
  effect_maintain($effect[Salamanderenity]);

  flavour_of_magic(loc);

// currently disabled until smarter methodology can be used to decide when to do this:
  if (my_meat() > 10000
      && my_level() < 13
      && false)
  {
    // limiter on this so we don't cause MP restores to use up all of our meat.

    effect_maintain($effect[Drescher's Annoying Noise]);
    effect_maintain($effect[Ur-Kel's Aria of Annoyance]);
  }
}

void cast_if(skill sk, boolean doit)
{
  if (!doit) return;
  if (!have_skill(sk)) return;
  if (!be_good(sk)) return;

  if (my_mp() < (mp_cost(sk) * 5)) return; // wait until we have an MP buffer

  use_skill(1, sk);
}

void cast_one_time_things()
{
  cast_if($skill[Advanced Cocktailcrafting], to_int(get_property("cocktailSummons")) == 0);
  cast_if($skill[Advanced Saucecrafting], to_int(get_property("reagentSummons")) == 0);
  cast_if($skill[Pastamastery], to_int(get_property("noodleSummons")) == 0);
  cast_if($skill[summon crimbo candy], to_int(get_property("_candySummons")) == 0);
  cast_if($skill[Summon Holiday Fun!], !to_boolean(get_property("_holidayFunUsed")));
}

void prep(location loc)
{

  if (have_effect($effect[somewhat poisoned]) > 0)
    uneffect($effect[somewhat poisoned]);

 if (my_path() != "Actually Ed the Undying")
 {
   if (have_effect($effect[beaten up]) > 0)
     uneffect($effect[beaten up]);

   if (my_hp() < (my_maxhp() * 0.75))
   {
     log("Restoring health...");
     restore_hp(my_maxhp() * 0.9);
   }

   // should put more finesse here to just recover what we need...
   if (my_mp() < (my_maxmp() * 0.5))
   {
     log("Restoring MP...");
     restore_mp(my_maxmp() * 0.6);
   }

 }

  while (my_meat() > 1000
      && setting("hermit_complete") != "true"
      && setting("no_clover") != "true"
      && my_path() != "Nuclear Autumn")
  {

    while ($coinmaster[hermit].available_tokens == 0)
    {
      if (!have($item[chewing gum on a string]))
        buy(1, $item[chewing gum on a string]);
      use(1, $item[chewing gum on a string]);
    }
    int qty = total_clovers();

    boolean gotcha = hermit(1, $item[ten-leaf clover]);
    if (!gotcha || qty == total_clovers())
    {
      save_daily_setting("hermit_complete", "true");
    }
  }

  consume();

  if (to_int(setting("adventure_floor", "10")) > my_adventures())
  {
    if (hippy_stone_broken())
    {
      cheat_deck("clubs", "more PvP");
    }
    if (!have_skill($skill[ancestral recall]))
    {
      cheat_deck("ancestral recall", "learn a skill for more adventures");
    } else
    {
      cheat_deck("ancestral recall", "get some " + wrap($item[blue mana]) + " for more adventures");
      cheat_deck("island", "get some " + wrap($item[blue mana]) + " for more adventures");
    }
  }

  heart();

  cast_things(loc);

  pulverize_things();
  sell_things();
  buy_things();
  make_things();
  use_things();
  closet_things();
  clan_things();

  prep_accordionthief(loc);
  prep_discobandit(loc);
  prep_pastamancer(loc);
  prep_sauceror(loc);
  prep_sealclubber(loc);
  prep_turtletamer(loc);

  prep_lta();

  cast_one_time_things();
  cast_surplus_mp();

  prep_fishing(loc);

  if (have($item[screencapped monster])
      && my_adventures() > 3
      && my_inebriety() <= inebriety_limit())
  {
    cli_execute("checkpoint");
    maximize();
    use(1, $item[screencapped monster]);
    cli_execute("outfit checkpoint");
  }

  maybe_pull($item[disassembled clover], 3);

  if (have_effect($effect[majorly poisoned]) > 0)
    uneffect($effect[majorly poisoned]);


  // auto_mcd() seems to be way too easy on us and sets it to 0 more than I'd like.
  //  if (loc != $location[none]) auto_mcd(loc);

  if (!($locations[the boss bat's lair,
                   Haert of the Cyrpt,
                   Throne Room] contains loc))
  {
    int annoy = 10;
    if (canadia_available()) annoy = 11;
    if (current_mcd() != annoy)
      change_mcd(annoy);
  }

  buy_skills();
}

void prep()
{
  prep($location[none]);
}


void main()
{
  prep();
}
