<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
 # Copyright (C) 2020-2024, Goldorion, opensource contributors
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
<#include "../mcitems.ftl">
<#include "../procedures.java.ftl">

package ${package}.entity;

<#compress>
public class ${name}Entity extends AbstractArrow implements ItemSupplier {

	public static final ItemStack PROJECTILE_ITEM = ${mappedMCItemToItemStackCode(data.projectileItem)};

	public ${name}Entity(EntityType<? extends ${name}Entity> type, Level world) {
		super(type, world);
	}

	public ${name}Entity(EntityType<? extends ${name}Entity> type, double x, double y, double z, Level world) {
		super(type, x, y, z, world);
	}

	public ${name}Entity(EntityType<? extends ${name}Entity> type, LivingEntity entity, Level world) {
		super(type, entity, world);
	}

	@Override public ItemStack getItem() {
		return PROJECTILE_ITEM;
	}

	@Override protected ItemStack getPickupItem() {
		return PROJECTILE_ITEM;
	}

	@Override protected void doPostHurtEffects(LivingEntity entity) {
		super.doPostHurtEffects(entity);
		entity.setArrowCount(entity.getArrowCount() - 1); <#-- #53957 -->
	}

	<#if hasProcedure(data.onHitsPlayer)>
	@Override public void playerTouch(Player entity) {
		super.playerTouch(entity);
		<@procedureCode data.onHitsPlayer, {
			"x": "this.getX()",
			"y": "this.getY()",
			"z": "this.getZ()",
			"entity": "entity",
			"sourceentity": "this.getOwner()",
			"immediatesourceentity": "this",
			"world": "this.level()"
		}/>
	}
	</#if>

	<#if hasProcedure(data.onHitsEntity)>
	@Override public void onHitEntity(EntityHitResult entityHitResult) {
		super.onHitEntity(entityHitResult);
		<@procedureCode data.onHitsEntity, {
			"x": "this.getX()",
			"y": "this.getY()",
			"z": "this.getZ()",
			"entity": "entityHitResult.getEntity()",
			"sourceentity": "this.getOwner()",
			"immediatesourceentity": "this",
			"world": "this.level()"
		}/>
	}
	</#if>

	<#if hasProcedure(data.onHitsBlock)>
	@Override public void onHitBlock(BlockHitResult blockHitResult) {
		super.onHitBlock(blockHitResult);
		<@procedureCode data.onHitsBlock, {
			"x": "blockHitResult.getBlockPos().getX()",
			"y": "blockHitResult.getBlockPos().getY()",
			"z": "blockHitResult.getBlockPos().getZ()",
			"entity": "this.getOwner()",
			"immediatesourceentity": "this",
			"world": "this.level()"
		}/>
	}
	</#if>

	@Override public void tick() {
		super.tick();

		<#if hasProcedure(data.onFlyingTick)>
			<@procedureCode data.onFlyingTick, {
				"x": "this.getX()",
				"y": "this.getY()",
				"z": "this.getZ()",
				"world": "this.level()",
				"entity": "this.getOwner()",
				"immediatesourceentity": "this"
			}/>
		</#if>

		if (this.inGround)
			this.discard();
	}

	public static ${name}Entity shoot(Level world, LivingEntity entity, RandomSource source) {
		return shoot(world, entity, source, ${data.power}f, ${data.damage}, ${data.knockback});
	}

	public static ${name}Entity shoot(Level world, LivingEntity entity, RandomSource random, float power, double damage, int knockback) {
		${name}Entity entityarrow = new ${name}Entity(${JavaModName}Entities.${data.getModElement().getRegistryNameUpper()}, entity, world);
		entityarrow.shoot(entity.getViewVector(1).x, entity.getViewVector(1).y, entity.getViewVector(1).z, power * 2, 0);
		entityarrow.setSilent(true);
		entityarrow.setCritArrow(${data.showParticles});
		entityarrow.setBaseDamage(damage);
		entityarrow.setKnockback(knockback);
		<#if data.igniteFire>
			entityarrow.setSecondsOnFire(100);
		</#if>
		world.addFreshEntity(entityarrow);

		<#if data.actionSound.toString()?has_content>
		world.playSound(null, entity.getX(), entity.getY(), entity.getZ(), BuiltInRegistries.SOUND_EVENT
				.get(new ResourceLocation("${data.actionSound}")), SoundSource.PLAYERS, 1, 1f / (random.nextFloat() * 0.5f + 1) + (power / 2));
		</#if>

		return entityarrow;
	}

	public static ${name}Entity shoot(LivingEntity entity, LivingEntity target) {
		${name}Entity entityarrow = new ${name}Entity(${JavaModName}Entities.${data.getModElement().getRegistryNameUpper()}, entity, entity.level());
		double dx = target.getX() - entity.getX();
		double dy = target.getY() + target.getEyeHeight() - 1.1;
		double dz = target.getZ() - entity.getZ();
		entityarrow.shoot(dx, dy - entityarrow.getY() + Math.hypot(dx, dz) * 0.2F, dz, ${data.power}f * 2, 12.0F);

		entityarrow.setSilent(true);
		entityarrow.setBaseDamage(${data.damage});
		entityarrow.setKnockback(${data.knockback});
		entityarrow.setCritArrow(${data.showParticles});
		<#if data.igniteFire>
			entityarrow.setSecondsOnFire(100);
		</#if>
		entity.level().addFreshEntity(entityarrow);

		<#if data.actionSound.toString()?has_content>
		entity.level().playSound(null, entity.getX(), entity.getY(), entity.getZ(), BuiltInRegistries.SOUND_EVENT
				.get(new ResourceLocation("${data.actionSound}")), SoundSource.PLAYERS, 1, 1f / (RandomSource.create().nextFloat() * 0.5f + 1));
		</#if>

		return entityarrow;
	}

}
</#compress>
<#-- @formatter:on -->
