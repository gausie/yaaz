string COLOR_ITEM = "green";
string COLOR_LOCATION = "blue";
string COLOR_EFFECT = "blue";
string COLOR_MONSTER = "blue";
string COLOR_SKILL = "green";
string COLOR_CLASS = "green";
string COLOR_COINMASTER = "blue";

string COLOR_ERROR = "red";
string COLOR_WARNING = "purple";
string COLOR_LOG = "#CD853F";
string COLOR_ADVICE = "purple";

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

string wrap(item i, int qty)
{
  return wrap(pluralize(qty, i), COLOR_ITEM);
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

string wrap(class c)
{
  return wrap(c, COLOR_CLASS);
}

string wrap(location l)
{
	return wrap(l, COLOR_LOCATION);
}

string wrap(effect e)
{
  return wrap(e, COLOR_EFFECT);
}

string wrap(coinmaster c)
{
  return wrap(c, COLOR_COINMASTER);
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

void advice(string msg)
{
  dg_print(msg, COLOR_ADVICE);
}


void progress(int percent);
void progress(int percent, string msg);
void progress(int qty, int total);
void progress(int qty, int total, string msg);

void progress(int percent)
{
  progress(percent, 100);
}

void progress(int qty, int total)
{
  progress(qty, total, "");
}

void progress(int percent, string msg)
{
  progress(percent, 100, msg);
}

void progress(int qty, int total, string msg)
{
  if (qty > total)
    qty = total;

  int percent = ((to_float(qty) / to_float(total)) * 100.0);

  string footer;
  if (total == 100)
  {
    footer = "&nbsp;" + qty + "%";
  } else {
    footer = "&nbsp;" + qty + "/" + total;
  }
  if (msg != "")
  {
    footer += "&nbsp;" + msg;
  }

  string div_style="border: 1px solid black; background-color: silver; width: 200px; position: relative; padding: 3px";
  string bar_style="background-color: green; width: " + percent + "%;";
  print_html("<div style='"+div_style+"'><div style='" + bar_style + "'>&nbsp;</div></div>&nbsp;" + footer);
}