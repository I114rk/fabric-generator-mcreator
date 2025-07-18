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
<#include "procedures.java.ftl">

package ${package}.client.particle;
import net.fabricmc.api.Environment;

@Environment(EnvType.CLIENT) public class ${name}Particle extends TextureSheetParticle {

	public static ${name}ParticleProvider provider(SpriteSet spriteSet) {
		return new ${name}ParticleProvider(spriteSet);
	}

	public static class ${name}ParticleProvider implements ParticleProvider<SimpleParticleType> {
		private final SpriteSet spriteSet;

		public ${name}ParticleProvider(SpriteSet spriteSet) {
			this.spriteSet = spriteSet;
		}

		public Particle createParticle(SimpleParticleType typeIn, ClientLevel worldIn, double x, double y, double z, double xSpeed, double ySpeed, double zSpeed) {
			return new ${name}Particle(worldIn, x, y, z, xSpeed, ySpeed, zSpeed, this.spriteSet);
		}
	}

	private final SpriteSet spriteSet;
	
	<#if data.angularVelocity != 0 || data.angularAcceleration != 0>
		private float angularVelocity;
		private float angularAcceleration;
	</#if>

	protected ${name}Particle(ClientLevel world, double x, double y, double z, double vx, double vy, double vz, SpriteSet spriteSet) {
		super(world, x, y, z);
		this.spriteSet = spriteSet;

		this.setSize((float) ${data.width}, (float) ${data.height});
		this.quadSize *= (float) ${data.scale};

		<#if (data.maxAgeDiff > 0)>
			this.lifetime = (int) Math.max(1, ${data.maxAge} + (this.random.nextInt(${data.maxAgeDiff * 2}) - ${data.maxAgeDiff}));
		<#else>
			this.lifetime = ${data.maxAge};
		</#if>

		this.gravity = (float) ${data.gravity};
		this.hasPhysics = ${data.canCollide};

		this.xd = vx * ${data.speedFactor};
		this.yd = vy * ${data.speedFactor};
		this.zd = vz * ${data.speedFactor};

		<#if data.angularVelocity != 0 || data.angularAcceleration != 0>
			this.angularVelocity = (float) ${data.angularVelocity};
			this.angularAcceleration = (float) ${data.angularAcceleration};
		</#if>

		<#if data.animate>
			this.setSpriteFromAge(spriteSet);
		<#else>
			this.pickSprite(spriteSet);
		</#if>
	}

	<#if data.renderType == "LIT">
		@Override public int getLightColor(float partialTick) {
			return 15728880;
		}
	</#if>

	@Override public ParticleRenderType getRenderType() {
		return ParticleRenderType.PARTICLE_SHEET_${data.renderType};
	}

	@Override public void tick() {
		super.tick();

		<#if data.angularVelocity != 0 || data.angularAcceleration != 0>
			this.oRoll = this.roll;
			this.roll += this.angularVelocity;
			this.angularVelocity += this.angularAcceleration;
		</#if>

		<#if data.animate>
			if(!this.removed) {
				<#assign frameCount = data.getTextureTileCount()>
				this.setSprite(this.spriteSet.get((this.age / ${data.frameDuration}) % ${frameCount} + 1, ${frameCount}));
			}
		</#if>

		<#if hasProcedure(data.additionalExpiryCondition)>
			double x = this.x;
			double y = this.y;
			double z = this.z;
			if (<@procedureOBJToConditionCode data.additionalExpiryCondition/>)
				this.remove();
		</#if>
	}

}
<#-- @formatter:on -->