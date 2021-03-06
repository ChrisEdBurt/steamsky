--    Copyright 2018-2019 Bartek thindil Jasicki
--
--    This file is part of Steam Sky.
--
--    Steam Sky is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Steam Sky is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with Steam Sky.  If not, see <http://www.gnu.org/licenses/>.

with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Label; use Gtk.Label;
with Gtk.Tree_Model; use Gtk.Tree_Model;
with Gtk.List_Store; use Gtk.List_Store;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Tree_View_Column; use Gtk.Tree_View_Column;
with Gtk.Tree_Selection; use Gtk.Tree_Selection;
with Gtk.Adjustment; use Gtk.Adjustment;
with Gtk.Stack; use Gtk.Stack;
with Gtk.Tree_Model_Filter; use Gtk.Tree_Model_Filter;
with Gtk.Combo_Box_Text; use Gtk.Combo_Box_Text;
with Glib; use Glib;
with Glib.Object; use Glib.Object;
with Gtkada.Builder; use Gtkada.Builder;
with Game; use Game;
with Maps; use Maps;
with Messages; use Messages;
with Ships; use Ships;
with Ships.Cargo; use Ships.Cargo;
with Items; use Items;
with Bases.Cargo; use Bases.Cargo;
with Utils.UI; use Utils.UI;
with Maps.UI; use Maps.UI;
with BasesTypes; use BasesTypes;

package body Bases.LootUI is

   -- ****iv* Bases.LootUI/SettingTime
   -- FUNCTION
   -- If true, UI is currently in setting state
   -- SOURCE
   SettingTime: Boolean;
   -- ****

   -- ****if* Bases.LootUI/ShowItemInfo
   -- FUNCTION
   -- Show detailed information about selected item
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure ShowItemInfo(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      ItemInfo, ProtoIndex: Unbounded_String;
      CargoIndex, BaseCargoIndex: Natural := 0;
      BaseIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
      ItemTypes: constant array(Positive range <>) of Unbounded_String :=
        (WeaponType, ChestArmor, HeadArmor, ArmsArmor, LegsArmor, ShieldType);
   begin
      declare
         ItemsIter: Gtk_Tree_Iter;
         ItemsModel: Gtk_Tree_Model;
      begin
         Get_Selected
           (Gtk.Tree_View.Get_Selection
              (Gtk_Tree_View(Get_Object(Object, "treeitems"))),
            ItemsModel, ItemsIter);
         if ItemsIter = Null_Iter then
            return;
         end if;
         CargoIndex := Natural(Get_Int(ItemsModel, ItemsIter, 1));
         if CargoIndex > Natural(PlayerShip.Cargo.Length) then
            return;
         end if;
         BaseCargoIndex := Natural(Get_Int(ItemsModel, ItemsIter, 2));
      end;
      if BaseCargoIndex > Natural(SkyBases(BaseIndex).Cargo.Length) then
         return;
      end if;
      if CargoIndex > 0 then
         ProtoIndex := PlayerShip.Cargo(CargoIndex).ProtoIndex;
      else
         ProtoIndex := SkyBases(BaseIndex).Cargo(BaseCargoIndex).ProtoIndex;
      end if;
      Append
        (ItemInfo,
         "Weight:" & Integer'Image(Items_List(ProtoIndex).Weight) & " kg");
      if Items_List(ProtoIndex).IType = WeaponType then
         Append
           (ItemInfo,
            LF & "Skill: " &
            To_String(Skills_List(Items_List(ProtoIndex).Value(3)).Name) &
            "/" &
            To_String
              (Attributes_List
                 (Skills_List(Items_List(ProtoIndex).Value(3)).Attribute)
                 .Name));
         if Items_List(ProtoIndex).Value(4) = 1 then
            Append(ItemInfo, LF & "Can be used with shield.");
         else
            Append
              (ItemInfo,
               LF & "Can't be used with shield (two-handed weapon).");
         end if;
         Append(ItemInfo, LF & "Damage type: ");
         case Items_List(ProtoIndex).Value(5) is
            when 1 =>
               Append(ItemInfo, "cutting");
            when 2 =>
               Append(ItemInfo, "impaling");
            when 3 =>
               Append(ItemInfo, "blunt");
            when others =>
               null;
         end case;
      end if;
      for ItemType of ItemTypes loop
         if Items_List(ProtoIndex).IType = ItemType then
            Append
              (ItemInfo,
               LF & "Damage chance: " &
               GetItemChanceToDamage(Items_List(ProtoIndex).Value(1)));
            Append
              (ItemInfo,
               LF & "Strength:" &
               Integer'Image(Items_List(ProtoIndex).Value(2)));
            exit;
         end if;
      end loop;
      if Tools_List.Contains(Items_List(ProtoIndex).IType) then
         Append
           (ItemInfo,
            LF & "Damage chance: " &
            GetItemChanceToDamage(Items_List(ProtoIndex).Value(1)));
      end if;
      if Length(Items_List(ProtoIndex).IType) > 4
        and then
        (Slice(Items_List(ProtoIndex).IType, 1, 4) = "Ammo" or
         Items_List(ProtoIndex).IType = To_Unbounded_String("Harpoon")) then
         Append
           (ItemInfo,
            LF & "Strength:" & Integer'Image(Items_List(ProtoIndex).Value(1)));
      end if;
      if Items_List(ProtoIndex).Description /= Null_Unbounded_String then
         Append
           (ItemInfo, LF & LF & To_String(Items_List(ProtoIndex).Description));
      end if;
      Set_Label
        (Gtk_Label(Get_Object(Object, "lbllootinfo")), To_String(ItemInfo));
      if CargoIndex = 0 then
         Set_Visible(Gtk_Widget(Get_Object(Object, "dropbox")), False);
      else
         Set_Visible(Gtk_Widget(Get_Object(Object, "dropbox")), True);
         Set_Upper
           (Gtk_Adjustment(Get_Object(Object, "amountadj")),
            Gdouble(PlayerShip.Cargo(CargoIndex).Amount));
      end if;
      if BaseCargoIndex = 0 then
         Set_Visible(Gtk_Widget(Get_Object(Object, "takebox")), False);
      elsif SkyBases(BaseIndex).Cargo(BaseCargoIndex).Amount > 0 then
         Set_Visible(Gtk_Widget(Get_Object(Object, "takebox")), True);
         Set_Upper
           (Gtk_Adjustment(Get_Object(Object, "amountadj1")),
            Gdouble(SkyBases(BaseIndex).Cargo(BaseCargoIndex).Amount));
      end if;
      declare
         FreeSpace: Integer := FreeCargo(0);
      begin
         if FreeSpace < 0 then
            FreeSpace := 0;
         end if;
         Set_Label
           (Gtk_Label(Get_Object(Object, "lblshipspace")),
            "Free cargo space:" & Integer'Image(FreeSpace) & " kg");
      end;
   end ShowItemInfo;

   -- ****if* Bases.LootUI/LootItem
   -- FUNCTION
   -- Take or add selected item to the base cargo to or from the player ship
   -- cargo
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure LootItem(User_Data: access GObject_Record'Class) is
      -- ****
      BaseIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
      Amount: Positive;
      CargoIndex, BaseCargoIndex: Natural := 0;
      ProtoIndex: Unbounded_String;
   begin
      declare
         ItemsIter: Gtk_Tree_Iter;
         ItemsModel: Gtk_Tree_Model;
      begin
         Get_Selected
           (Gtk.Tree_View.Get_Selection
              (Gtk_Tree_View(Get_Object(Builder, "treeitems"))),
            ItemsModel, ItemsIter);
         if ItemsIter = Null_Iter then
            return;
         end if;
         CargoIndex := Natural(Get_Int(ItemsModel, ItemsIter, 1));
         BaseCargoIndex := Natural(Get_Int(ItemsModel, ItemsIter, 2));
      end;
      if CargoIndex > 0 then
         ProtoIndex := PlayerShip.Cargo(CargoIndex).ProtoIndex;
      else
         ProtoIndex := SkyBases(BaseIndex).Cargo(BaseCargoIndex).ProtoIndex;
      end if;
      if User_Data = Get_Object(Builder, "btntakeall") then
         Amount := SkyBases(BaseIndex).Cargo(BaseCargoIndex).Amount;
      elsif User_Data = Get_Object(Builder, "btndropall") then
         Amount := PlayerShip.Cargo(CargoIndex).Amount;
      elsif User_Data = Get_Object(Builder, "btndrop") then
         Amount :=
           Positive
             (Get_Value(Gtk_Adjustment(Get_Object(Builder, "amountadj1"))));
      else
         Amount :=
           Positive
             (Get_Value(Gtk_Adjustment(Get_Object(Builder, "amountadj"))));
      end if;
      if User_Data = Get_Object(Builder, "btndropall") or
        User_Data = Get_Object(Builder, "btndrop") then
         if BaseCargoIndex > 0 then
            UpdateBaseCargo
              (CargoIndex => BaseCargoIndex, Amount => Amount,
               Durability => PlayerShip.Cargo.Element(CargoIndex).Durability);
         else
            UpdateBaseCargo
              (ProtoIndex, Amount,
               PlayerShip.Cargo.Element(CargoIndex).Durability);
         end if;
         UpdateCargo
           (Ship => PlayerShip, CargoIndex => CargoIndex,
            Amount => (0 - Amount),
            Durability => PlayerShip.Cargo.Element(CargoIndex).Durability);
         AddMessage
           ("You drop" & Positive'Image(Amount) & " " &
            To_String(Items_List(ProtoIndex).Name) & ".",
            OrderMessage);
      else
         if FreeCargo(0 - (Amount * Items_List(ProtoIndex).Weight)) < 0 then
            ShowDialog
              ("You can't take that much " &
               To_String(Items_List(ProtoIndex).Name) & ".");
            return;
         end if;
         if CargoIndex > 0 then
            UpdateCargo
              (Ship => PlayerShip, CargoIndex => CargoIndex, Amount => Amount,
               Durability =>
                 SkyBases(BaseIndex).Cargo(BaseCargoIndex).Durability);
         else
            UpdateCargo
              (PlayerShip, ProtoIndex, Amount,
               SkyBases(BaseIndex).Cargo(BaseCargoIndex).Durability);
         end if;
         UpdateBaseCargo
           (CargoIndex => BaseCargoIndex, Amount => (0 - Amount),
            Durability =>
              SkyBases(BaseIndex).Cargo.Element(BaseCargoIndex).Durability);
         AddMessage
           ("You took" & Positive'Image(Amount) & " " &
            To_String(Items_List(ProtoIndex).Name) & ".",
            OrderMessage);
      end if;
      UpdateGame(10);
      ShowLootUI;
   end LootItem;

   -- ****if* Bases.LootUI/SearchLoot
   -- FUNCTION
   -- Search the item by its name
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure SearchLoot(Object: access Gtkada_Builder_Record'Class) is
   -- ****
   begin
      Refilter(Gtk_Tree_Model_Filter(Get_Object(Object, "lootfilter")));
      if N_Children
          (Gtk_List_Store(Get_Object(Builder, "itemslist2")), Null_Iter) >
        0 then
         Set_Cursor
           (Gtk_Tree_View(Get_Object(Builder, "treeitems")),
            Gtk_Tree_Path_New_From_String("0"), null, False);
      end if;
   end SearchLoot;

   -- ****if* Bases.LootUI/VisibleLoot
   -- FUNCTION
   -- Check if selected item is visible on items list
   -- Model - Gtk_Tree_Model with items list which will be checked
   -- Iter  - Gtk_Tree_Iter of item which will be checked
   -- RESULT
   -- True if item should be visible, otherwise false
   -- SOURCE
   function VisibleLoot
     (Model: Gtk_Tree_Model; Iter: Gtk_Tree_Iter) return Boolean is
      -- ****
      IType: constant Unbounded_String :=
        To_Unbounded_String
          (Get_Active_Text
             (Gtk_Combo_Box_Text(Get_Object(Builder, "cmbloottype"))));
      ProtoIndex: Unbounded_String;
      BaseIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
   begin
      if SettingTime then
         return True;
      end if;
      if IType = To_Unbounded_String("All") then
         return True;
      else
         if Get_Int(Model, Iter, 1) > 0 then
            ProtoIndex :=
              PlayerShip.Cargo(Positive(Get_Int(Model, Iter, 1))).ProtoIndex;
         else
            ProtoIndex :=
              SkyBases(BaseIndex).Cargo(Positive(Get_Int(Model, Iter, 2)))
                .ProtoIndex;
         end if;
         if Items_List(ProtoIndex).IType = IType or
           Items_List(ProtoIndex).ShowType = IType then
            return True;
         end if;
      end if;
      return False;
   end VisibleLoot;

   procedure CreateBasesLootUI is
   begin
      Register_Handler(Builder, "Show_Item_Info", ShowItemInfo'Access);
      Register_Handler(Builder, "Loot_Item", LootItem'Access);
      Register_Handler(Builder, "Search_Loot", SearchLoot'Access);
      On_Key_Press_Event
        (Gtk_Widget(Get_Object(Builder, "spinloottake")), SelectElement'Access,
         Get_Object(Builder, "btntake"));
      On_Key_Press_Event
        (Gtk_Widget(Get_Object(Builder, "spinlootdrop")), SelectElement'Access,
         Get_Object(Builder, "btndrop"));
      Set_Visible_Func
        (Gtk_Tree_Model_Filter(Get_Object(Builder, "lootfilter")),
         VisibleLoot'Access);
   end CreateBasesLootUI;

   procedure ShowLootUI is
      ItemsIter: Gtk_Tree_Iter;
      ItemsList: constant Gtk_List_Store :=
        Gtk_List_Store(Get_Object(Builder, "itemslist2"));
      BaseIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
      IndexesList: Positive_Container.Vector;
      BaseCargoIndex: Natural;
      ProtoIndex: Unbounded_String;
      Visible: Boolean := False;
      ItemsTypes: UnboundedString_Container.Vector;
      procedure AddType is
      begin
         if not ItemsTypes.Contains(Items_List(ProtoIndex).IType) and
           not ItemsTypes.Contains(Items_List(ProtoIndex).ShowType) then
            if Items_List(ProtoIndex).ShowType = Null_Unbounded_String then
               ItemsTypes.Append(Items_List(ProtoIndex).IType);
            else
               ItemsTypes.Append(Items_List(ProtoIndex).ShowType);
            end if;
         end if;
      end AddType;
   begin
      SettingTime := True;
      ItemsTypes.Append(To_Unbounded_String("All"));
      Clear(ItemsList);
      for I in PlayerShip.Cargo.Iterate loop
         if Get_Price
             (SkyBases(BaseIndex).BaseType, PlayerShip.Cargo(I).ProtoIndex) >
           0 then
            Append(ItemsList, ItemsIter);
            Set(ItemsList, ItemsIter, 0, GetItemName(PlayerShip.Cargo(I)));
            Set
              (ItemsList, ItemsIter, 1, Gint(Inventory_Container.To_Index(I)));
            ProtoIndex := PlayerShip.Cargo(I).ProtoIndex;
            BaseCargoIndex :=
              FindBaseCargo(ProtoIndex, PlayerShip.Cargo(I).Durability);
            if BaseCargoIndex > 0 then
               IndexesList.Append(New_Item => BaseCargoIndex);
            end if;
            Set(ItemsList, ItemsIter, 2, Gint(BaseCargoIndex));
            if Items_List(ProtoIndex).ShowType = Null_Unbounded_String then
               Set
                 (ItemsList, ItemsIter, 3,
                  To_String(Items_List(ProtoIndex).IType));
            else
               Set
                 (ItemsList, ItemsIter, 3,
                  To_String(Items_List(ProtoIndex).ShowType));
            end if;
            AddType;
            if PlayerShip.Cargo(I).Durability < 100 then
               Set
                 (ItemsList, ItemsIter, 5,
                  " " & GetItemDamage(PlayerShip.Cargo(I).Durability) & " ");
               Set(ItemsList, ItemsIter, 6, True);
               Visible := True;
            end if;
            Set(ItemsList, ItemsIter, 4, Gint(PlayerShip.Cargo(I).Durability));
            Set(ItemsList, ItemsIter, 7, Gint(PlayerShip.Cargo(I).Amount));
            if BaseCargoIndex > 0 then
               Set
                 (ItemsList, ItemsIter, 8,
                  Gint(SkyBases(BaseIndex).Cargo(BaseCargoIndex).Amount));
            end if;
         end if;
      end loop;
      for I in
        SkyBases(BaseIndex).Cargo.First_Index ..
          SkyBases(BaseIndex).Cargo.Last_Index loop
         if IndexesList.Find_Index(Item => I) = 0 then
            Append(ItemsList, ItemsIter);
            ProtoIndex := SkyBases(BaseIndex).Cargo(I).ProtoIndex;
            Set
              (ItemsList, ItemsIter, 0,
               To_String(Items_List(ProtoIndex).Name));
            Set(ItemsList, ItemsIter, 1, 0);
            Set(ItemsList, ItemsIter, 2, Gint(I));
            if Items_List(ProtoIndex).ShowType = Null_Unbounded_String then
               Set
                 (ItemsList, ItemsIter, 3,
                  To_String(Items_List(ProtoIndex).IType));
            else
               Set
                 (ItemsList, ItemsIter, 3,
                  To_String(Items_List(ProtoIndex).ShowType));
            end if;
            AddType;
            if SkyBases(BaseIndex).Cargo(I).Durability < 100 then
               Set
                 (ItemsList, ItemsIter, 5,
                  " " &
                  GetItemDamage(SkyBases(BaseIndex).Cargo(I).Durability) &
                  " ");
               Set(ItemsList, ItemsIter, 6, True);
               Visible := True;
            end if;
            Set
              (ItemsList, ItemsIter, 4,
               Gint(SkyBases(BaseIndex).Cargo(I).Durability));
            Set
              (ItemsList, ItemsIter, 8,
               Gint(SkyBases(BaseIndex).Cargo(I).Amount));
         end if;
      end loop;
      declare
         TypesCombo: constant Gtk_Combo_Box_Text :=
           Gtk_Combo_Box_Text(Get_Object(Builder, "cmbloottype"));
      begin
         Remove_All(TypesCombo);
         for IType of ItemsTypes loop
            Append_Text(TypesCombo, To_String(IType));
         end loop;
         Set_Active(TypesCombo, 0);
      end;
      Set_Visible
        (Gtk_Tree_View_Column(Get_Object(Builder, "columnlootdurability")),
         Visible);
      Set_Visible_Child_Name
        (Gtk_Stack(Get_Object(Builder, "gamestack")), "loot");
      Hide(Gtk_Widget(Get_Object(Builder, "dropbox")));
      Hide(Gtk_Widget(Get_Object(Builder, "takebox")));
      Set_Cursor
        (Gtk_Tree_View(Get_Object(Builder, "treeitems")),
         Gtk_Tree_Path_New_From_String("0"), null, False);
      UpdateMessages;
      SettingTime := False;
   end ShowLootUI;

end Bases.LootUI;
