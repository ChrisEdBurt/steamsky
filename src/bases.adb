--    Copyright 2016 Bartek thindil Jasicki
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

with Ships; use Ships;
with Maps; use Maps;
with UserInterface; use UserInterface;
with Game; use Game;

package body Bases is

    procedure BuyItems(ItemIndex : Positive; Amount : String) is
        BuyAmount : Positive;
        BaseIndex : constant Positive := SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
        Cost : Positive;
        MoneyIndex : Natural := 0;
    begin
        BuyAmount := Positive'Value(Amount);
        if not SkyBases(BaseIndex).Goods(ItemIndex).Buyable then
            return;
        end if;
        Cost := BuyAmount * SkyBases(BaseIndex).Goods(ItemIndex).Price;
        for I in PlayerShip.Cargo.First_Index..PlayerShip.Cargo.Last_Index loop
            if PlayerShip.Cargo.Element(I).Name = "Charcollum" then
                MoneyIndex := I;
                exit;
            end if;
        end loop;
        if MoneyIndex = 0 then
            return;
        end if;
        if Cost > PlayerShip.Cargo.Element(MoneyIndex).Amount then
            return;
        end if;
        UpdateCargo(To_Unbounded_String("Charcollum"), (0 - Cost), 1);
        UpdateCargo(SkyBases(BaseIndex).Goods(ItemIndex).Name, BuyAmount,
            SkyBases(BaseIndex).Goods(ItemIndex).Weight);
        AddMessage("You bought" & Positive'Image(BuyAmount) & " " & To_String(SkyBases(BaseIndex).Goods(ItemIndex).Name) &
            " for" & Positive'Image(Cost) & " Charcollum.");
        UpdateGame(5);
    exception
        when others =>
            return;
    end BuyItems;

    procedure SellItems(ItemIndex : Positive; Amount : String) is
        SellAmount : Positive;
        BaseIndex : constant Positive := SkyMap(PlayerShip.SkyX, PlayerShip.SkyY).BaseIndex;
        Profit : Positive;
        BaseItemIndex : Natural := 0;
    begin
        SellAmount := Positive'Value(Amount);
        if PlayerShip.Cargo.Element(ItemIndex).Amount < SellAmount then
            return;
        end if;
        for I in SkyBases(BaseIndex).Goods'Range loop
            if SkyBases(BaseIndex).Goods(I).Name = PlayerShip.Cargo.Element(ItemIndex).Name then
                BaseItemIndex := I;
                exit;
            end if;
        end loop;
        UpdateCargo(SkyBases(BaseIndex).Goods(BaseItemIndex).Name, (0 -
            SellAmount), SkyBases(BaseIndex).Goods(BaseItemIndex).Weight);
        Profit := SkyBases(BaseIndex).Goods(BaseItemIndex).Price * SellAmount;
        UpdateCargo(To_Unbounded_String("Charcollum"), Profit, 1);
        AddMessage("You sold" & Positive'Image(SellAmount) & " " & To_String(SkyBases(BaseIndex).Goods(BaseItemIndex).Name) &
            " for" & Positive'Image(Profit) & " Charcollum.");
        UpdateGame(5);
    exception
        when others =>
            return;
    end SellItems;

end Bases;
