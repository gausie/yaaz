boolean is_vip_item(item it);
boolean can_vip_drink();
boolean can_vip_drink(item it);
boolean can_vip();

// Note: more complex Clan VIP items have their own entry, like the Floundry.


boolean can_vip()
{
  return (item_amount($item[clan vip lounge key]) > 0);
}

boolean can_vip_drink()
{
  return can_vip() && to_int(get_property("_speakeasyDrinksDrunk")) < 3;
}

boolean can_vip_drink(item it)
{
  if (!is_vip_item(it))
    return false;
  if (!can_vip_drink())
    return false;

  int yum = it.inebriety;

  if (my_path() == "Nuclear Autumn" && yum > 1)
    return false;

  int room = inebriety_limit() - my_inebriety();
  return yum <= room;
}

boolean is_vip_item(item it)
{
  if ($items[glass of &quot;milk&quot;,
             cup of &quot;tea&quot;,
             thermos of &quot;whiskey&quot;,
             Lucky Lindy,
             Bee's Knees,
             Sockdollager,
             Ish Kabibble,
             Hot Socks,
             Phonus Balonus,
             Flivver,
             Sloppy Jalopy] contains it)
    return true;
  return false;
}