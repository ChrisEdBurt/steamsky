--    Copyright 2016-2018 Bartek thindil Jasicki
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

with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with DOM.Readers; use DOM.Readers;
with ShipModules; use ShipModules;
with Game; use Game;
with Ships; use Ships;

package Crafts is

   type Craft_Data is -- Data structure for recipes
   record
      MaterialTypes: UnboundedString_Container
        .Vector; -- Types of material needed for recipe
      MaterialAmounts: Positive_Container
        .Vector; -- Amounts of material needed for recipe
      ResultIndex: Positive; -- Prototype index of crafted item
      ResultAmount: Natural; -- Amount of products
      Workplace: ModuleType; -- Ship module needed for crafting
      Skill: Positive; -- Skill used in crafting item
      Time: Positive; -- Minutes needed for finish recipe
      Difficulty: Positive; -- How difficult is recipe to discover
      BaseType: Natural; -- Sky base type in which recipe can be bought
      Tool: Unbounded_String; -- Type of tool used to craft item
      Index: Unbounded_String; -- Index of recipe
   end record;
   package Recipes_Container is new Vectors(Positive, Craft_Data);
   Recipes_List: Recipes_Container.Vector; -- List of recipes available in game
   Known_Recipes: Positive_Container
     .Vector; -- List of all know by player recipes
   Crafting_No_Materials: exception; -- Raised when no materials needed for selected recipe
   Crafting_No_Tools: exception; -- Raised when no tool needed for selected recipe
   Crafting_No_Workshop: exception; -- Raised when no workshop needed for selected recipe

   procedure LoadRecipes(Reader: Tree_Reader); -- Load recipes from files
   procedure Manufacturing(Minutes: Positive); -- Craft selected items
   function CheckRecipe(RecipeIndex: Integer) return Positive with
      Pre => RecipeIndex <=
      Recipes_List
        .Last_Index; -- Check if player have all requirements for selected recipe, return max amount of items which can be craft
   function FindRecipe(Index: Unbounded_String) return Natural with
      Pre => Index /=
      Null_Unbounded_String; -- Return vector index of recipe or zero if recipe not found
   procedure SetRecipe(Workshop, Amount: Positive; RecipeIndex: Integer) with
      Pre =>
      (Workshop <= PlayerShip.Modules.Last_Index and
       RecipeIndex <=
         Known_Recipes
           .Last_Index); -- Set crafting recipe for selected workshop

end Crafts;
