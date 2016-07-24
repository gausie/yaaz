string COLOR_ITEM = "green";
string COLOR_LOCATION = "blue";
string COLOR_EFFECT = "purple";
string COLOR_MONSTER = "purple";
string COLOR_SKILL = "purple";

string COLOR_ERROR = "red";
string COLOR_WARNING = "purple";
string COLOR_LOG = "#CD853F";

string pluralize(int count, item it)
{
  if (count == 1)
    return it;
  return to_plural(it);
}

string wrap(string i, string color)
{
	return ("<font color='" + color + "'>" + i + "</font>");
}

string wrap(item i)
{
	return wrap(i, COLOR_ITEM);
}

string wrap(familiar f)
{
	return wrap(f, COLOR_ITEM);
}

string wrap(monster m)
{
  return wrap(m, COLOR_MONSTER);
}

string wrap(skill s)
{
  return wrap(s, COLOR_SKILL);
}

string wrap(location l)
{
	return wrap(l, COLOR_LOCATION);
}

string wrap(effect e)
{
  return wrap(e, COLOR_EFFECT);
}

void dg_print(string msg, string color)
{
  print_html("<font color='" + color + "'>" + msg + "</font>");
}

void log(string msg)
{
	dg_print(msg, COLOR_LOG);
}

void log_adv(int turns, string msg)
{
  string adv = "adventures";
  if (turns == 1)
    adv = "adventure";
  log("It took " + turns + " " + adv + " " + msg);
}

void error(string msg)
{
  dg_print(msg, COLOR_ERROR);
}

void warning(string msg)
{
  dg_print(msg, COLOR_WARNING);
}

void warning_no_estimate()
{
  warning("No estimated turns available for this step yet.");
}
