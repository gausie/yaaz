import "util/base/yz_print.ash";
import <zlib.ash>;

float frequency_of_monster(location loc, monster mon);
boolean bit_flag(int progress, int c);
boolean guild_class();
float avg_meat_per_adv(location loc);
float cost_per_mp();
boolean guild_store_open();
float average_range(string avg);
boolean can_adventure();
boolean[skill] perm_skills();
void skill_recommendation();

// these really should be in effects.ash, but are here to avoid an import loop.
// Need to sort this sort of problem out sometime...
void uneffect(effect ef);
void uneffect_song();
int songs_in_head();
int max_songs();
boolean can_cast_song();
int approx_pool_skill();

string SCRIPT = "yaaz";
string DATA_DIR = "scripts/" + SCRIPT + "/util/data/";

int abort_on_advs_left = 3;


void skill_recommendation()
{
  boolean[skill] permed = perm_skills();

  // skills in "recommended to perm" order. Certainly a subjective list, but
  // at least we can give a basic recommendation. List largely pulled from
  // the wiki's hardcore skill analysis page.
  boolean[skill] recs = $skills[pulverize,
                                ambidextrous funkslinging,
                                advanced saucecrafting,
                                pastamastery,
                                the ode to booze,
                                cannelloni cocoon,
                                tongue of the walrus,
                                advanced cocktailcrafting,
                                amphibian sympathy,
                                saucemaven,
                                smooth movement,
                                the sonata of sneakiness,
                                superhuman cocktailcrafting,
                                torso awaregness,
                                mad looting skillz,
                                leash of linguini,
                                fat leon's phat loot lyric,
                                tao of the terrapin,
                                hero of the half-shell,
                                springy fusilli,
                                nimble fingers,
                                ur-kel's aria of annoyance,
                                disco fever,
                                rage of the reindeer,
                                the power ballad of the arrowsmith,
                                lunging thrust-smack,
                                powers of observatiogn,
                                musk of the moose,
                                carlweather's cantata of confrontation,
                                overdeveloped sense of self preservation,
                                saucestorm,
                                flavour of magic,
                                wisdom of the elder tortoises,
                                inner sauce,
                                thief among the honorable,
                                impetuous sauciness,
                                the way of sauce,
                                transcendental noodlecraft,
                                the magical mojomuscular melody,
                                armorcraftiness,
                                adventurer of leisure,
                                empathy of the newt,
                                astral shell];

  foreach sk in recs
  {
    if (permed contains sk) continue;
    if (sk.class != my_class()) continue;
    warning("When ascending, I'd recommend making " + wrap(sk) + " permanent.");
    return;
  }
}


boolean[skill] perm_skills()
{
  boolean[skill] perms;
  string b=visit_url("showplayer.php?who="+my_id());
  if (contains_text(b, "class=\"pskill\">"))
  {
    b=substring(b,b.index_of("class=\"pskill\">"),b.index_of("Clan: <b>"));
    foreach sk in $skills[]
    {
      if (!have_skill(sk)) continue;

  // do we want to include skills you've permed but only in softcore?
//      if (b.index_of(">" + sk + " (P)") > 0) perms[sk] = true;
//      if (b.index_of(">" + sk + "</a> (P)") > 0) perms[sk] = true;

      if (b.index_of(">" + sk + " (<") > 0) perms[sk] = true;
      if (b.index_of(">" + sk + "</a> (<") > 0) perms[sk] = true;

    }
  }
  return perms;
}

int element_damage_bonus(element el)
{
  // return the total (elemental) damage bonus against an element.
  float hot = numeric_modifier("hot damage");
  float cold = numeric_modifier("cold damage");
  float stench = numeric_modifier("stench damage");
  float sleaze = numeric_modifier("sleaze damage");
  float spooky = numeric_modifier("spooky damage");

  switch (el)
  {
    case $element[hot]:
      return min(1, hot) + cold + spooky + 2 * stench + 2 * sleaze;
    case $element[cold]:
      return min(1, cold) + sleaze + stench + 2 * hot + 2 * spooky;
    case $element[stench]:
      return min(1, stench) + hot + spooky + 2 * cold + 2 * sleaze;
    case $element[sleaze]:
      return min(1, sleaze) + hot + stench + 2 * spooky + 2 * cold;
    case $element[spooky]:
      return min(1, spooky) + cold + sleaze + 2 * hot + 2 * stench;
  }
  return 0;
}

int approx_pool_skill()
{
  int pool = 0;
  if (my_inebriety() <= 10)
  {
    pool += my_inebriety();
  } else {
    pool += 10 - (my_inebriety() - 10) * 2;
  }

  pool += to_int(get_property("poolSkill"));

  pool += numeric_modifier("pool skill");

  pool += min(10,floor(2.0 * square_root(to_float(get_property("poolSharkCount")))));

  return pool;
}

int smiles_remaining()
{

  int total_casts_available = to_int(get_property("goldenMrAccessories")) * 5;
  int casts_used = to_int(get_property("_smilesOfMrA"));

  return total_casts_available - casts_used;
}

int total_smiles()
{
	return to_int(get_property("goldenMrAccessories")) * 5;
}

int elemental_resitance(element goal)
{
	return numeric_modifier(goal + " resistance");
}

boolean can_adventure()
{
  if (my_adventures() <= abort_on_advs_left)
    return false;
  if (my_inebriety() > inebriety_limit())
    return false;
  return true;
}

float average_range(string avg)
{
  // turns strings like "1-5" into the average of the string ("3")
  // useful for things like consumables which sometimes express
  // values as ranges (adventures for food, for instance)

  if (!contains_text(avg, "-"))
    return to_float(avg);

  string[int] avgs = split_string(avg, "-");
  return ((to_int(avgs[0]) + to_int(avgs[1])) / 2);
}


boolean guild_store_open()
{
  return (get_property("lastGuildStoreOpen").to_int() == my_ascensions());
}


float cost_per_mp()
{
  if (my_class() == $class[Pastamancer] || my_class() == $class[Sauceror] || (my_class() == $class[accordion thief] && my_level() >= 9))
  {
    // has access to MMJ
    int cost = npc_price($item[magical mystery juice]);
    float restore =  (1.5 * my_level()) + 5;
    return cost/restore;
  }
  return 17.5; // soda water
}

float avg_meat_per_adv(location loc)
{
  monster [int] monster_list = get_monsters(loc);
  float avg_meat = 0;
  int counter = 0;
  foreach i in monster_list {
     avg_meat += (meat_drop(monster_list[i]) * frequency_of_monster(loc, monster_list[i]) / 100);
  }
  return avg_meat;
}

float frequency_of_monster(location loc, monster mon)
{
  foreach mob, freq in appearance_rates(loc)
  {
    if (mob == mon)
    {
      return freq;
    }
  }
  return 0;
}

boolean bit_flag(int progress, int c)
{
	return (progress & (1 << c)) != 0;
}

boolean is_guild_class()
{
	return ($classes[Seal Clubber, Turtle Tamer, Sauceror, Pastamancer, Disco Bandit, Accordion Thief] contains my_class());
}

skill to_skill(thrall slave)
{
  return slave.skill;
}

boolean is_turtle_buff(skill sk)
{
  return (sk.class == $class[turtle tamer] && sk.buff);
}

boolean is_turtle_buff(effect ef)
{
  skill sk = to_skill(ef);
  return is_turtle_buff(sk);
}

boolean is_sauceror_buff(skill sk)
{
  return (sk.class == $class[sauceror] && sk.buff);
}

boolean is_sauceror_buff(effect ef)
{
  skill sk = to_skill(ef);
  return is_sauceror_buff(sk);
}

boolean is_thief_buff(skill sk)
{
  return (sk.class == $class[accordion thief] && sk.buff);
}

boolean is_thief_buff(effect ef)
{
  skill sk = to_skill(ef);
  return is_thief_buff(sk);
}

int songs_in_head()
{
  int count = 0;
  foreach buff in my_effects()
  {
    if (is_thief_buff(buff))
      count++;
  }
  return count;
}

int max_songs()
{
  // this obviously could be handled better...
  if (have_skill($skill[mariachi memory])) return 4;
  return 3;
}

boolean can_cast_song()
{
  return songs_in_head() < max_songs();
}

void uneffect_song()
{
  effect song = $effect[none];
  foreach ef in my_effects()
  {
    if (!is_thief_buff(ef)) continue;
    if (have_effect(ef) < have_effect(song) || song == $effect[none])
    {
      song = ef;
    }
  }
  uneffect(song);
}

boolean uneffect(effect ef)
{
	if(have_effect(ef) == 0)
		return true;

	if(cli_execute("uneffect " + ef))
		return true;

  if (ef == $effect[beaten up] && have_effect(ef) > 0)
  {
    // not great, but don't have a better plan right now.
    log("Unsure how else to get rid of " + wrap(ef) + ", so going to take a quick rest.");
    wait(3);
    cli_execute("rest");
  }

	if(item_amount($item[Soft Green Echo Eyedrop Antidote]) > 0)
	{
    log("Removing the effect " + wrap(ef) + " with a " + wrap($item[Soft Green Echo Eyedrop Antidote]) + ".");
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(ef));
		return true;
	}
	return false;
}
