<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
 # Copyright (C) 2020-2023, Goldorion, opensource contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "../procedures.java.ftl">
<#include "../mcitems.ftl">
<#include "../triggers.java.ftl">

<#assign tabMap = w.getCreativeTabMap()>
<#assign vanillaTabs = tabMap.keySet()?filter(e -> !e?starts_with('CUSTOM:'))>
<#assign customTabs = tabMap.keySet()?filter(e -> e?starts_with('CUSTOM:'))>

package ${package}.item;

import net.minecraft.world.entity.ai.attributes.Attributes;
import com.google.common.collect.Multimap;
import net.minecraft.world.item.CreativeModeTabs;

public class ${name}Item extends Item {

	public ${name}Item() {
		super(new Item.Properties()
				<#if data.hasInventory()>
					.stacksTo(1)
				<#elseif data.damageCount != 0>
					.durability(${data.damageCount})
				<#else>
					.stacksTo(${data.stackSize})
				</#if>
				<#if data.immuneToFire>
					.fireResistant()
				</#if>
				.rarity(Rarity.${data.rarity})
				<#if data.isFood>
					.food((new FoodProperties.Builder())
						.nutrition(${data.nutritionalValue})
						.saturationMod(${data.saturation}f)
						<#if data.isAlwaysEdible>.alwaysEat()</#if>
						<#if data.isMeat>.meat()</#if>
						.build())
				</#if>
		);
        <#list vanillaTabs as tabName>
        	<#list tabMap.get(tabName) as tabElement>
                <#if tabElement == "CUSTOM:" + name>
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

	<#if data.hasNonDefaultAnimation()>
		@Override public UseAnim getUseAnimation(ItemStack itemstack) {
			return UseAnim.${data.animation?upper_case};
		}
	</#if>

	<#if data.stayInGridWhenCrafting>
		@Override public boolean hasCraftingRemainingItem() {
			return true;
		}

		<#if data.recipeRemainder?? && !data.recipeRemainder.isEmpty()>
			@Override public ItemStack getRecipeRemainder(ItemStack itemstack) {
				return ${mappedMCItemToItemStackCode(data.recipeRemainder, 1)};
			}
		<#elseif data.damageOnCrafting && data.damageCount != 0>
			@Override public ItemStack getRecipeRemainder(ItemStack itemstack) {
				ItemStack retval = new ItemStack(this);
				retval.setDamageValue(itemstack.getDamageValue() + 1);
				if(retval.getDamageValue() >= retval.getMaxDamage()) {
					return ItemStack.EMPTY;
				}
				return retval;
			}
		<#else>
			@Override public ItemStack getRecipeRemainder(ItemStack itemstack) {
				return new ItemStack(this);
			}
		</#if>
	</#if>

	<#if data.enchantability != 0>
		@Override public int getEnchantmentValue() {
			return ${data.enchantability};
		}
	</#if>

	@Override public int getUseDuration(ItemStack itemstack) {
		return ${data.useDuration};
	}

	<#if data.toolType != 1>
		@Override public float getDestroySpeed(ItemStack par1ItemStack, BlockState par2Block) {
			return ${data.toolType}F;
		}
	</#if>

	<#if data.enableMeleeDamage>
		@Override public Multimap<Attribute, AttributeModifier> getDefaultAttributeModifiers(EquipmentSlot equipmentSlot) {
			if (equipmentSlot == EquipmentSlot.MAINHAND) {
				ImmutableMultimap.Builder<Attribute, AttributeModifier> builder = ImmutableMultimap.builder();
				builder.putAll(super.getDefaultAttributeModifiers(equipmentSlot));
				builder.put(Attributes.ATTACK_DAMAGE, new AttributeModifier(BASE_ATTACK_DAMAGE_UUID, "Item modifier", ${data.damageVsEntity - 2}d, AttributeModifier.Operation.ADDITION));
				builder.put(Attributes.ATTACK_SPEED, new AttributeModifier(BASE_ATTACK_SPEED_UUID, "Item modifier", -2.4, AttributeModifier.Operation.ADDITION));
				return builder.build();
			}
			return super.getDefaultAttributeModifiers(equipmentSlot);
		}
	</#if>

	<@hasGlow data.glowCondition/>

	<#if data.destroyAnyBlock>
		@Override public boolean isCorrectToolForDrops(BlockState state) {
			return true;
		}
	</#if>

	<@addSpecialInformation data.specialInformation/>

	<#if hasProcedure(data.onRightClickedInAir) || data.hasInventory() || (hasProcedure(data.onStoppedUsing) && (data.useDuration > 0)) || data.enableRanged>
		@Override public InteractionResultHolder<ItemStack> use(Level world, Player entity, InteractionHand hand) {
			<#if data.enableRanged>
				InteractionResultHolder<ItemStack> ar = InteractionResultHolder.success(entity.getItemInHand(hand));
			<#else>
				InteractionResultHolder<ItemStack> ar = super.use(world, entity, hand);
			</#if>

			<#if (hasProcedure(data.onStoppedUsing) && (data.useDuration > 0)) || data.enableRanged>
            	entity.startUsingItem(hand);
            </#if>

			<#if data.hasInventory()>
				entity.openMenu(new ExtendedScreenHandlerFactory() {
					@Override
					public AbstractContainerMenu createMenu(int syncId, Inventory inventory, Player player) {
						return new ${data.guiBoundTo}Menu(syncId, inventory, new ${name}Inventory(itemstack));
					}

					@Override
					public Component getDisplayName() {
						return itemstack.getDisplayName();
					}

					@Override
					public void writeScreenOpeningData(ServerPlayer player, FriendlyByteBuf buf) {
						buf.writeBlockPos(BlockPos.ZERO);
					}
				});
			</#if>

            <#if hasProcedure(data.onRightClickedInAir)>
                <@procedureCode data.onRightClickedInAir, {
                    "x": "entity.getX()",
                    "y": "entity.getY()",
                    "z": "entity.getZ()",
                    "world": "world",
                    "entity": "entity",
                    "itemstack": "ar.getObject()"
                }/>
            </#if>
			return ar;
		}
	</#if>

	<#if hasProcedure(data.onFinishUsingItem) || data.hasEatResultItem()>
		@Override public ItemStack finishUsingItem(ItemStack itemstack, Level world, LivingEntity entity) {
			ItemStack retval =
				<#if data.hasEatResultItem()>
					${mappedMCItemToItemStackCode(data.eatResultItem, 1)};
				</#if>
			super.finishUsingItem(itemstack, world, entity);

			<#if hasProcedure(data.onFinishUsingItem)>
				double x = entity.getX();
				double y = entity.getY();
				double z = entity.getZ();
				<@procedureOBJToCode data.onFinishUsingItem/>
			</#if>

			<#if data.hasEatResultItem()>
				if (itemstack.isEmpty()) {
					return retval;
				} else {
					if (entity instanceof Player player && !player.getAbilities().instabuild) {
						if (!player.getInventory().add(retval))
							player.drop(retval, false);
					}
					return itemstack;
				}
			<#else>
				return retval;
			</#if>
		}
	</#if>

	<@onItemUsedOnBlock data.onRightClickedOnBlock/>

	<@onEntityHitWith data.onEntityHitWith/>

	<@onCrafted data.onCrafted/>

	<@onItemTick data.onItemInUseTick, data.onItemInInventoryTick/>

	<#if hasProcedure(data.onStoppedUsing) || (data.enableRanged && !data.shootConstantly)>
		@Override public void releaseUsing(ItemStack itemstack, Level world, LivingEntity entity, int time) {
			<#if hasProcedure(data.onStoppedUsing)>
				<@procedureCode data.onStoppedUsing, {
					"x": "entity.getX()",
					"y": "entity.getY()",
					"z": "entity.getZ()",
					"world": "world",
					"entity": "entity",
					"itemstack": "itemstack",
					"time": "time"
				}/>
			</#if>
			<#if data.enableRanged && !data.shootConstantly>
				if (!world.isClientSide() && entity instanceof ServerPlayer player) {
					<#if hasProcedure(data.rangedUseCondition)>
						double x = entity.getX();
						double y = entity.getY();
						double z = entity.getZ();
						if (<@procedureOBJToConditionCode data.rangedUseCondition/>) {
							<@arrowShootCode/>
						}
					<#else>
						<@arrowShootCode/>
					</#if>
				}
			</#if>
		}
	</#if>

	<#if data.enableRanged && data.shootConstantly>
		@Override public void onUseTick(Level world, LivingEntity entity, ItemStack itemstack, int count) {
			if (!world.isClientSide() && entity instanceof ServerPlayer player) {
				<#if hasProcedure(data.rangedUseCondition)>
					double x = entity.getX();
					double y = entity.getY();
					double z = entity.getZ();
					if (<@procedureOBJToConditionCode data.rangedUseCondition/>) {
						<@arrowShootCode/>
						entity.releaseUsingItem();
					}
				<#else>
					<@arrowShootCode/>
					entity.releaseUsingItem();
				</#if>
			}
		}
	</#if>
}

<#macro arrowShootCode>
	<#assign projectile = data.projectile.getUnmappedValue()>
	ItemStack stack = ProjectileWeaponItem.getHeldProjectile(entity, e -> e.getItem() == ${generator.map(projectile, "projectiles", 2)});
	if(stack == ItemStack.EMPTY) {
		for (int i = 0; i < player.getInventory().items.size(); i++) {
			ItemStack teststack = player.getInventory().items.get(i);
			if(teststack != null && teststack.getItem() == ${generator.map(projectile, "projectiles", 2)}) {
				stack = teststack;
				break;
			}
		}
	}

	if (player.getAbilities().instabuild || stack != ItemStack.EMPTY) {
		<#assign projectileClass = generator.map(projectile, "projectiles", 0)>
		<#if projectile.startsWith("CUSTOM:")>
			${projectileClass} projectile = ${projectileClass}.shoot(world, entity, world.getRandom());
		<#elseif projectile.endsWith("Arrow")>
			${projectileClass} projectile = new ${projectileClass}(world, entity);
			projectile.shootFromRotation(entity, entity.getXRot(), entity.getYRot(), 0, 3.15f, 1.0F);
			world.addFreshEntity(projectile);
			world.playSound(null, entity.getX(), entity.getY(), entity.getZ(), ForgeRegistries.SOUND_EVENTS
				.getValue(new ResourceLocation("entity.arrow.shoot")), SoundSource.PLAYERS, 1, 1f / (world.getRandom().nextFloat() * 0.5f + 1));
		</#if>

		itemstack.hurtAndBreak(1, entity, e -> e.broadcastBreakEvent(entity.getUsedItemHand()));

		if (player.getAbilities().instabuild) {
			projectile.pickup = AbstractArrow.Pickup.CREATIVE_ONLY;
		} else {
			if (stack.isDamageableItem()){
				if (stack.hurt(1, world.getRandom(), player)) {
					stack.shrink(1);
					stack.setDamageValue(0);
					if (stack.isEmpty())
						player.getInventory().removeItem(stack);
				}
			} else{
				stack.shrink(1);
				if (stack.isEmpty())
				   player.getInventory().removeItem(stack);
			}
		}

		<#if hasProcedure(data.onRangedItemUsed)>
			<@procedureOBJToCode data.onRangedItemUsed/>
		</#if>
	}
</#macro>
<#-- @formatter:on -->