--    Copyright 2017 Bartek thindil Jasicki
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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers; use Ada.Containers;
with Maps; use Maps;
with Messages; use Messages;
with Items; use Items;
with Ships; use Ships;
with Ships.Cargo; use Ships.Cargo;
with Ships.Crew; use Ships.Crew;
with Events; use Events;
with Crew; use Crew;
with Game; use Game;
with Utils; use Utils;

package body Trades is

   procedure BuyItems(BaseItemIndex: Positive; Amount: String) is
      BuyAmount, TraderIndex, Price, ProtoMoneyIndex: Positive;
      BaseIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
      BaseType, ItemIndex: Positive;
      Cost, MoneyIndex2: Natural;
      EventIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).EventIndex;
      ItemName: Unbounded_String;
   begin
      BuyAmount := Positive'Value(Amount);
      if BaseIndex > 0 then
         BaseType := Bases_Types'Pos(SkyBases(BaseIndex).BaseType) + 1;
         ItemIndex := SkyBases(BaseIndex).Cargo(BaseItemIndex).ProtoIndex;
         if not Items_List(ItemIndex).Buyable(BaseType) then
            raise Trade_Cant_Buy with To_String(ItemName);
         end if;
         if SkyBases(BaseIndex).Cargo(BaseItemIndex).Amount = 0 then
            raise Trade_Not_For_Sale_Now with To_String(ItemName);
         elsif SkyBases(BaseIndex).Cargo(BaseItemIndex).Amount < BuyAmount then
            raise Trade_Buying_Too_Much with To_String(ItemName);
         end if;
         Price := SkyBases(BaseIndex).Cargo(BaseItemIndex).Price;
         if EventIndex > 0 then
            if Events_List(EventIndex).EType = DoublePrice and
              Events_List(EventIndex).Data = ItemIndex then
               Price := Price * 2;
            end if;
         end if;
      else
         ItemIndex := TraderCargo(BaseItemIndex).ProtoIndex;
         if TraderCargo(BaseItemIndex).Amount < BuyAmount then
            raise Trade_Buying_Too_Much with To_String(ItemName);
         end if;
         Price := TraderCargo(BaseItemIndex).Price;
      end if;
      ItemName := Items_List(ItemIndex).Name;
      TraderIndex := FindMember(Talk);
      Cost := BuyAmount * Price;
      CountPrice(Cost, TraderIndex);
      ProtoMoneyIndex := FindProtoItem(MoneyIndex);
      MoneyIndex2 := FindCargo(ProtoMoneyIndex);
      if FreeCargo(Cost - (Items_List(ItemIndex).Weight * BuyAmount)) < 0 then
         raise Trade_No_Free_Cargo;
      end if;
      if MoneyIndex2 = 0 then
         raise Trade_No_Money with To_String(ItemName);
      end if;
      if Cost > PlayerShip.Cargo(MoneyIndex2).Amount then
         raise Trade_Not_Enough_Money with To_String(ItemName);
      end if;
      UpdateCargo
        (Ship => PlayerShip,
         CargoIndex => MoneyIndex2,
         Amount => (0 - Cost));
      if BaseIndex > 0 then
         UpdateBaseCargo(ProtoMoneyIndex, Cost);
      else
         TraderCargo(1).Amount := TraderCargo(1).Amount + Cost;
      end if;
      UpdateCargo
        (PlayerShip,
         ItemIndex,
         BuyAmount,
         SkyBases(BaseIndex).Cargo(BaseItemIndex).Durability);
      if BaseIndex > 0 then
         UpdateBaseCargo
           (CargoIndex => BaseItemIndex,
            Amount => (0 - BuyAmount),
            Durability =>
              SkyBases(BaseIndex).Cargo.Element(BaseItemIndex).Durability);
         GainRep(BaseIndex, 1);
      else
         TraderCargo(BaseItemIndex).Amount :=
           TraderCargo(BaseItemIndex).Amount - BuyAmount;
         if TraderCargo(BaseItemIndex).Amount = 0 then
            TraderCargo.Delete(Index => BaseItemIndex, Count => 1);
         end if;
      end if;
      GainExp(1, 4, TraderIndex);
      AddMessage
        ("You bought" &
         Positive'Image(BuyAmount) &
         " " &
         To_String(ItemName) &
         " for" &
         Positive'Image(Cost) &
         " " &
         To_String(MoneyName) &
         ".",
         TradeMessage);
      UpdateGame(5);
   exception
      when Constraint_Error =>
         raise Trade_Invalid_Amount;
   end BuyItems;

   procedure SellItems(ItemIndex: Positive; Amount: String) is
      SellAmount, TraderIndex: Positive;
      BaseIndex: constant Positive :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
      BaseType: constant Positive :=
        Bases_Types'Pos(SkyBases(BaseIndex).BaseType) + 1;
      ProtoIndex: constant Positive := PlayerShip.Cargo(ItemIndex).ProtoIndex;
      ItemName: constant String := To_String(Items_List(ProtoIndex).Name);
      Profit, Price: Positive;
      EventIndex: constant Natural :=
        SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).EventIndex;
      MoneyIndex2: constant Positive := FindProtoItem(MoneyIndex);
      BaseItemIndex: constant Natural := FindBaseCargo(ProtoIndex);
   begin
      SellAmount := Positive'Value(Amount);
      if PlayerShip.Cargo(ItemIndex).Amount < SellAmount then
         raise Trade_Too_Much_For_Sale with ItemName;
      end if;
      TraderIndex := FindMember(Talk);
      if BaseItemIndex = 0 then
         Price := Items_List(ProtoIndex).Prices(BaseType);
      else
         Price := SkyBases(BaseIndex).Cargo(BaseItemIndex).Price;
      end if;
      if EventIndex > 0 then
         if Events_List(EventIndex).EType = DoublePrice and
           Events_List(EventIndex).Data = ProtoIndex then
            Price := Price * 2;
         end if;
      end if;
      Profit := Price * SellAmount;
      if PlayerShip.Cargo(ItemIndex).Durability < 100 then
         Profit :=
           Positive
             (Float'Floor
                (Float(Profit) *
                 (Float(PlayerShip.Cargo(ItemIndex).Durability) / 100.0)));
      end if;
      CountPrice(Profit, TraderIndex, False);
      if FreeCargo((Items_List(ProtoIndex).Weight * SellAmount) - Profit) <
        0 then
         raise Trade_No_Free_Cargo;
      end if;
      if Profit > SkyBases(BaseIndex).Cargo(1).Amount then
         raise Trade_No_Money_In_Base with ItemName;
      end if;
      UpdateBaseCargo
        (ProtoIndex,
         SellAmount,
         PlayerShip.Cargo.Element(ItemIndex).Durability);
      UpdateCargo
        (Ship => PlayerShip,
         CargoIndex => ItemIndex,
         Amount => (0 - SellAmount),
         Durability => PlayerShip.Cargo.Element(ItemIndex).Durability);
      UpdateCargo(PlayerShip, MoneyIndex2, Profit);
      UpdateBaseCargo(MoneyIndex2, (0 - Profit));
      GainExp(1, 4, TraderIndex);
      GainRep(BaseIndex, 1);
      AddMessage
        ("You sold" &
         Positive'Image(SellAmount) &
         " " &
         ItemName &
         " for" &
         Positive'Image(Profit) &
         " " &
         To_String(MoneyName) &
         ".",
         TradeMessage);
      UpdateGame(5);
   exception
      when Constraint_Error =>
         raise Trade_Invalid_Amount;
   end SellItems;

   procedure GenerateTraderCargo(ProtoIndex: Positive) is
      TraderShip: ShipRecord :=
        CreateShip
          (ProtoIndex,
           Null_Unbounded_String,
           PlayerShip.SkyX,
           PlayerShip.SkyY,
           FULL_STOP);
      BaseType, CargoAmount, CargoItemIndex: Natural;
      ItemIndex, ItemAmount: Positive;
   begin
      TraderCargo.Clear;
      for Item of TraderShip.Cargo loop
         BaseType := GetRandom(0, 3);
         TraderCargo.Append
         (New_Item =>
            (ProtoIndex => Item.ProtoIndex,
             Amount => Item.Amount,
             Durability => 100,
             Price => Items_List(Item.ProtoIndex).Prices(BaseType)));
      end loop;
      if TraderShip.Crew.Length < 5 then
         CargoAmount := GetRandom(1, 3);
      elsif TraderShip.Crew.Length < 10 then
         CargoAmount := GetRandom(1, 5);
      else
         CargoAmount := GetRandom(1, 10);
      end if;
      while CargoAmount > 0 loop
         ItemIndex := GetRandom(Items_List.First_Index, Items_List.Last_Index);
         if TraderShip.Crew.Length < 5 then
            ItemAmount := GetRandom(1, 100);
         elsif TraderShip.Crew.Length < 10 then
            ItemAmount := GetRandom(1, 500);
         else
            ItemAmount := GetRandom(1, 1000);
         end if;
         CargoItemIndex :=
           FindCargo(ProtoIndex => ItemIndex, Ship => TraderShip);
         if CargoItemIndex > 0 then
            TraderCargo(CargoItemIndex).Amount :=
              TraderCargo(CargoItemIndex).Amount + ItemAmount;
            TraderShip.Cargo(CargoItemIndex).Amount :=
              TraderShip.Cargo(CargoItemIndex).Amount + ItemAmount;
         else
            if FreeCargo(0 - (Items_List(ItemIndex).Weight * ItemAmount)) >
              -1 then
               BaseType := GetRandom(0, 3);
               TraderCargo.Append
               (New_Item =>
                  (ProtoIndex => ItemIndex,
                   Amount => ItemAmount,
                   Durability => 100,
                   Price => Items_List(ItemIndex).Prices(BaseType)));
               TraderShip.Cargo.Append
               (New_Item =>
                  (ProtoIndex => ItemIndex,
                   Amount => ItemAmount,
                   Durability => 100,
                   Name => Null_Unbounded_String));
            else
               CargoAmount := 1;
            end if;
         end if;
         CargoAmount := CargoAmount - 1;
      end loop;
   end GenerateTraderCargo;

end Trades;
