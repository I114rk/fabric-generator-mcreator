<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
 # Copyright (C) 2020-2023, Goldorion, opensource contributors
 #
 # Fabric-Generator-MCreator is free software: you can redistribute it and/or modify
 # it under the terms of the GNU Lesser General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # Fabric-Generator-MCreator is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU Lesser General Public License for more details.
 #
 # You should have received a copy of the GNU Lesser General Public License
 # along with Fabric-Generator-MCreator.  If not, see <https://www.gnu.org/licenses/>.
-->

<#-- @formatter:off -->
<#include "mcitems.ftl">
<#include "procedures.java.ftl">
<#include "triggers.java.ftl">

<#assign tabMap = w.getCreativeTabMap()>
<#assign vanillaTabs = tabMap.keySet()?filter(e -> !e?starts_with('CUSTOM:'))>
<#assign customTabs = tabMap.keySet()?filter(e -> e?starts_with('CUSTOM:'))>

package ${package}.item;

import net.minecraft.sounds.SoundEvent;
import net.fabricmc.api.Environment;

public abstract class ${name}Item extends ArmorItem {

	public ${name}Item(Type type, Item.Properties properties) {
		super(new ArmorMaterial() {
			@Override public int getDurabilityForType(Type type) {
				return new int[]{13, 15, 16, 11}[type.getSlot().getIndex()] * ${data.maxDamage};
			}

			@Override public int getDefenseForType(Type type) {
				return new int[] { ${data.damageValueBoots}, ${data.damageValueLeggings}, ${data.damageValueBody}, ${data.damageValueHelmet} }[type.getSlot().getIndex()];
			}

			@Override public int getEnchantmentValue() {
				return ${data.enchantability};
			}

			@Override public SoundEvent getEquipSound() {
				<#if data.equipSound.getMappedValue()?has_content>
					<#if data.equipSound.getUnmappedValue().startsWith("CUSTOM:")>
						return ${JavaModName}Sounds.${data.equipSound?replace(modid + ":", "")?upper_case};
					<#else>
					<#assign s=data.equipSound>
						return BuiltInRegistries.SOUND_EVENT.get(new ResourceLocation("${s}"));
					</#if>
				<#else>
					return null;
				</#if>
			}

			@Override public Ingredient getRepairIngredient() {
				return ${mappedMCItemsToIngredient(data.repairItems)};
			}

			@Environment(EnvType.CLIENT)
			@Override public String getName() {
				return "${data.armorTextureFile}";
			}

			@Override public float getToughness() {
				return ${data.toughness}f;
			}

			@Override public float getKnockbackResistance() {
				return ${data.knockbackResistance}f;
			}
		}, type, properties);
	}

	<#if data.enableHelmet>
		public static class Helmet extends ${name}Item {

			public Helmet() {
				super(Type.HELMET, new Item.Properties()<#if data.helmetImmuneToFire>.fireResistant()</#if>);

        <#list vanillaTabs as tabName>
        	<#list tabMap.get(tabName) as tabElement>
                <#if tabElement + "Armor" == "CUSTOM:" + name>
                    <#if tabName == "DECORATIONS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.NATURAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "REDSTONE">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.REDSTONE_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "FOOD">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FOOD_AND_DRINKS).register(content -> content.accept(this));
                    <#elseif tabName == "TOOLS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.TOOLS_AND_UTILITIES).register(content -> content.accept(this));
                    <#elseif tabName == "MATERIALS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.INGREDIENTS).register(content -> content.accept(this));
                    <#elseif tabName == "MISC">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.SPAWN_EGGS).register(content -> content.accept(this));
                    <#elseif tabName == "TRANSPORTATION">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FUNCTIONAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "BREWING">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.COLORED_BLOCKS).register(content -> content.accept(this));
                    <#else>
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.${tabName}).register(content -> content.accept(this));
                    </#if>
                </#if>
        	</#list>
        </#list>

        <#list customTabs as tabName>
            <#list tabMap.get(tabName) as tabElement>
                <#if tabElement == "CUSTOM:" + name>
                    <#assign modifiedTabName = tabName.replace("CUSTOM:", "")?upper_case>
                    ItemGroupEvents.modifyEntriesEvent(${JavaModName}Tabs.TAB_${modifiedTabName}).register(content -> content.accept(this));
                </#if>
            </#list>
        </#list>

			}

		    <@addSpecialInformation data.helmetSpecialInformation/>

			<#if hasProcedure(data.onHelmetTick)>
				@Override
				public void inventoryTick(ItemStack itemstack, Level world, Entity entity, int slotinv, boolean selected) {
					double unique = Math.random();
					ItemStack stack = entity instanceof LivingEntity _entGetArmor ? _entGetArmor.getItemBySlot(EquipmentSlot.HEAD) : ItemStack.EMPTY;
					if (stack.getItem() == (itemstack).getItem()) {
						if (stack.getOrCreateTag().getDouble("_id") != unique)
							stack.getOrCreateTag().putDouble("_id", unique);
						if (itemstack.getOrCreateTag().getDouble("_id") == unique)
							<@onArmorTick data.onHelmetTick/>
					}
				}
			</#if>
				}
	</#if>

	<#if data.enableBody>
		public static class Chestplate extends ${name}Item {

			public Chestplate() {
				super(Type.CHESTPLATE, new Item.Properties()<#if data.bodyImmuneToFire>.fireResistant()</#if>);

        <#list vanillaTabs as tabName>
        	<#list tabMap.get(tabName) as tabElement>
                <#if tabElement + "Armor" == "CUSTOM:" + name>
                    <#if tabName == "DECORATIONS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.NATURAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "REDSTONE">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.REDSTONE_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "FOOD">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FOOD_AND_DRINKS).register(content -> content.accept(this));
                    <#elseif tabName == "TOOLS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.TOOLS_AND_UTILITIES).register(content -> content.accept(this));
                    <#elseif tabName == "MATERIALS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.INGREDIENTS).register(content -> content.accept(this));
                    <#elseif tabName == "MISC">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.SPAWN_EGGS).register(content -> content.accept(this));
                    <#elseif tabName == "TRANSPORTATION">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FUNCTIONAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "BREWING">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.COLORED_BLOCKS).register(content -> content.accept(this));
                    <#else>
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.${tabName}).register(content -> content.accept(this));
                    </#if>
                </#if>
        	</#list>
        </#list>

        <#list customTabs as tabName>
            <#list tabMap.get(tabName) as tabElement>
                <#if tabElement == "CUSTOM:" + name>
                    <#assign modifiedTabName = tabName.replace("CUSTOM:", "")?upper_case>
                    ItemGroupEvents.modifyEntriesEvent(${JavaModName}Tabs.TAB_${modifiedTabName}).register(content -> content.accept(this));
                </#if>
            </#list>
        </#list>

			}

		    <@addSpecialInformation data.bodySpecialInformation/>

			<#if hasProcedure(data.onBodyTick)>
				@Override
				public void inventoryTick(ItemStack itemstack, Level world, Entity entity, int slotinv, boolean selected) {
					double unique = Math.random();
					ItemStack stack = entity instanceof LivingEntity _entGetArmor ? _entGetArmor.getItemBySlot(EquipmentSlot.CHEST) : ItemStack.EMPTY;
					if (stack.getItem() == (itemstack).getItem()) {
						if (stack.getOrCreateTag().getDouble("_id") != unique)
							stack.getOrCreateTag().putDouble("_id", unique);
						if (itemstack.getOrCreateTag().getDouble("_id") == unique)
							<@onArmorTick data.onBodyTick/>
					}
				}
			</#if>
		}
	</#if>

	<#if data.enableLeggings>
		public static class Leggings extends ${name}Item {

			public Leggings() {
				super(Type.LEGGINGS, new Item.Properties()<#if data.leggingsImmuneToFire>.fireResistant()</#if>);

        <#list vanillaTabs as tabName>
        	<#list tabMap.get(tabName) as tabElement>
                <#if tabElement + "Armor" == "CUSTOM:" + name>
                    <#if tabName == "DECORATIONS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.NATURAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "REDSTONE">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.REDSTONE_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "FOOD">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FOOD_AND_DRINKS).register(content -> content.accept(this));
                    <#elseif tabName == "TOOLS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.TOOLS_AND_UTILITIES).register(content -> content.accept(this));
                    <#elseif tabName == "MATERIALS">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.INGREDIENTS).register(content -> content.accept(this));
                    <#elseif tabName == "MISC">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.SPAWN_EGGS).register(content -> content.accept(this));
                    <#elseif tabName == "TRANSPORTATION">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FUNCTIONAL_BLOCKS).register(content -> content.accept(this));
                    <#elseif tabName == "BREWING">
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.COLORED_BLOCKS).register(content -> content.accept(this));
                    <#else>
                        ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.${tabName}).register(content -> content.accept(this));
                    </#if>
                </#if>
        	</#list>
        </#list>

        <#list customTabs as tabName>
            <#list tabMap.get(tabName) as tabElement>
                <#if tabElement == "CUSTOM:" + name>
                    <#assign modifiedTabName = tabName.replace("CUSTOM:", "")?upper_case>
                    ItemGroupEvents.modifyEntriesEvent(${JavaModName}Tabs.TAB_${modifiedTabName}).register(content -> content.accept(this));
                </#if>
            </#list>
        </#list>

			}

		    <@addSpecialInformation data.leggingsSpecialInformation/>

			<#if hasProcedure(data.onLeggingsTick)>
				@Override
				public void inventoryTick(ItemStack itemstack, Level world, Entity entity, int slotinv, boolean selected) {
					double unique = Math.random();
					ItemStack stack = entity instanceof LivingEntity _entGetArmor ? _entGetArmor.getItemBySlot(EquipmentSlot.LEGS) : ItemStack.EMPTY;
					if (stack.getItem() == (itemstack).getItem()) {
						if (stack.getOrCreateTag().getDouble("_id") != unique)
							stack.getOrCreateTag().putDouble("_id", unique);
						if (itemstack.getOrCreateTag().getDouble("_id") == unique)
							<@onArmorTick data.onLeggingsTick/>
					}
				}
			</#if>
		}
	</#if>

	<#if data.enableBoots>
		public static class Boots extends ${name}Item {

			public Boots() {
				super(Type.BOOTS, new Item.Properties()<#if data.bootsImmuneToFire>.fireResistant()</#if>);

		        <#list vanillaTabs as tabName>
                	<#list tabMap.get(tabName) as tabElement>
                        <#if tabElement + "Armor" == "CUSTOM:" + name>
                            <#if tabName == "DECORATIONS">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.NATURAL_BLOCKS).register(content -> content.accept(this));
                            <#elseif tabName == "REDSTONE">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.REDSTONE_BLOCKS).register(content -> content.accept(this));
                            <#elseif tabName == "FOOD">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FOOD_AND_DRINKS).register(content -> content.accept(this));
                            <#elseif tabName == "TOOLS">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.TOOLS_AND_UTILITIES).register(content -> content.accept(this));
                            <#elseif tabName == "MATERIALS">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.INGREDIENTS).register(content -> content.accept(this));
                            <#elseif tabName == "MISC">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.SPAWN_EGGS).register(content -> content.accept(this));
                            <#elseif tabName == "TRANSPORTATION">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.FUNCTIONAL_BLOCKS).register(content -> content.accept(this));
                            <#elseif tabName == "BREWING">
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.COLORED_BLOCKS).register(content -> content.accept(this));
                            <#else>
                                ItemGroupEvents.modifyEntriesEvent(CreativeModeTabs.${tabName}).register(content -> content.accept(this));
                            </#if>
                        </#if>
                	</#list>
                </#list>

                <#list customTabs as tabName>
                    <#list tabMap.get(tabName) as tabElement>
                        <#if tabElement == "CUSTOM:" + name>
                            <#assign modifiedTabName = tabName.replace("CUSTOM:", "")?upper_case>
                            ItemGroupEvents.modifyEntriesEvent(${JavaModName}Tabs.TAB_${modifiedTabName}).register(content -> content.accept(this));
                        </#if>
                    </#list>
                </#list>

			}

		    <@addSpecialInformation data.bootsSpecialInformation/>

			<#if hasProcedure(data.onBootsTick)>
				@Override
				public void inventoryTick(ItemStack itemstack, Level world, Entity entity, int slotinv, boolean selected) {
					double unique = Math.random();
					ItemStack stack = entity instanceof LivingEntity _entGetArmor ? _entGetArmor.getItemBySlot(EquipmentSlot.FEET) : ItemStack.EMPTY;
					if (stack.getItem() == (itemstack).getItem()) {
						if (stack.getOrCreateTag().getDouble("_id") != unique)
							stack.getOrCreateTag().putDouble("_id", unique);
						if (itemstack.getOrCreateTag().getDouble("_id") == unique)
							<@onArmorTick data.onBootsTick/>
					}
				}
			</#if>
		}
	</#if>

}
<#-- @formatter:on -->