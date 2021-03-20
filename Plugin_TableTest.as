#name "Table example"
#author "Miss"
#category "Examples"

/* This example shows how the tables UI works. It consists of the basics, which is simply drawing
 * the rows and columns, as well as sorting.
 */

class Item
{
	int m_a;
	int m_b;
	float m_c;
	float m_d;
}

array<Item@> g_items;

// This bool exists for 2 reasons:
//   1. So columns can be sorted when the list of items changed
//   2. So columns can be sorted after a plugin reload (first rendered frame)
bool g_itemsDirty;

void AddNewItem()
{
	auto newItem = Item();
	newItem.m_a = Math::Rand(0, 1000000);
	newItem.m_b = Math::Rand(0, 999999);
	newItem.m_c = Math::Rand(0.0f, 100.0f);
	newItem.m_d = Math::Rand(100.0f, 500.0f);
	g_items.InsertLast(newItem);
	g_itemsDirty = true;
}

void ClearItems()
{
	g_items.RemoveRange(0, g_items.Length);
	g_itemsDirty = true;
}

void RandomItems()
{
	ClearItems();

	int numItems = Math::Rand(5, 25);
	for (int i = 0; i < numItems; i++) {
		AddNewItem();
	}
}

void SortItems(UI::TableSortSpecs@ sortSpecs)
{
	// Trying to sort an array of less than 2 items will throw an index out of bounds exception
	if (g_items.Length < 2) {
		return;
	}

	auto specs = sortSpecs.Specs;
	for (uint i = 0; i < specs.Length; i++) {
		auto spec = specs[i];

		// If there is no direction specified, we just skip it
		if (spec.SortDirection == UI::SortDirection::None) {
			continue;
		}

		// Sort based on direction
		if (spec.SortDirection == UI::SortDirection::Ascending) {
			// Sort ascending based on column index
			switch (spec.ColumnIndex) {
			case 0: g_items.Sort(function(a, b) { return a.m_a < b.m_a; }); break;
			case 1: g_items.Sort(function(a, b) { return a.m_b < b.m_b; }); break;
			case 2: g_items.Sort(function(a, b) { return a.m_c < b.m_c; }); break;
			case 3: g_items.Sort(function(a, b) { return a.m_d < b.m_d; }); break;
			}

		} else if (spec.SortDirection == UI::SortDirection::Descending) {
			// Sort descending based on column index
			switch (spec.ColumnIndex) {
			case 0: g_items.Sort(function(a, b) { return a.m_a > b.m_a; }); break;
			case 1: g_items.Sort(function(a, b) { return a.m_b > b.m_b; }); break;
			case 2: g_items.Sort(function(a, b) { return a.m_c > b.m_c; }); break;
			case 3: g_items.Sort(function(a, b) { return a.m_d > b.m_d; }); break;
			}
		}
	}

	// Clear dirty flags
	sortSpecs.Dirty = false;
	g_itemsDirty = false;
}

void RenderInterface()
{
	if (UI::Begin("Table test", UI::WindowFlags::NoCollapse | UI::WindowFlags::MenuBar)) {
		if (UI::BeginMenuBar()) {
			if (UI::MenuItem("Add item")) { AddNewItem(); }
			if (UI::MenuItem("Clear items")) { ClearItems(); }
			if (UI::MenuItem("Randomize items")) { RandomItems(); }
			UI::EndMenuBar();
		}

		// Make sure the UI::TableFlags::Sortable flag is used here
		if (UI::BeginTable("Items", 4, UI::TableFlags::Sortable | UI::TableFlags::Resizable)) {
			// Set up table columns
			UI::TableSetupColumn("A", UI::TableColumnFlags::WidthFixed, 100);
			UI::TableSetupColumn("B", UI::TableColumnFlags::WidthFixed | UI::TableColumnFlags::DefaultSort | UI::TableColumnFlags::PreferSortDescending, 100);
			UI::TableSetupColumn("C", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("D", UI::TableColumnFlags::WidthFixed, 100);
			UI::TableHeadersRow();

			// Perform the actual sorting here when the sorting specs are marked as dirty (user changed
			// table sorting) or the items array is marked as dirty (new or removed items)
			auto sortSpecs = UI::TableGetSortSpecs();
			if (sortSpecs !is null && (sortSpecs.Dirty || g_itemsDirty)) {
				SortItems(sortSpecs);
			}

			// Draw the items
			for (uint i = 0; i < g_items.Length; i++) {
				auto item = g_items[i];
				UI::TableNextRow();
				UI::TableSetColumnIndex(0);
				UI::Text("" + item.m_a);
				UI::TableSetColumnIndex(1);
				UI::Text("\\$f77" + item.m_b);
				UI::TableSetColumnIndex(2);
				UI::Text("\\$7f7" + item.m_c);
				UI::TableSetColumnIndex(3);
				UI::Text("\\$ff7" + item.m_d);
			}

			UI::EndTable();
		}
	}
	UI::End();
}

void Main()
{
	RandomItems();
}
