<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
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
package ${package}.world.features.configurations;

import com.mojang.serialization.Codec;

public record StructureFeatureConfiguration(ResourceLocation structure, boolean randomRotation, boolean randomMirror, HolderSet<Block> ignoredBlocks, Vec3i offset) implements FeatureConfiguration {
	public static final Codec<StructureFeatureConfiguration> CODEC = RecordCodecBuilder.create(builder -> {
		return builder.group(ResourceLocation.CODEC.fieldOf("structure").forGetter(config -> {
			return config.structure;
		}), Codec.BOOL.fieldOf("random_rotation").orElse(false).forGetter(config -> {
			return config.randomRotation;
		}), Codec.BOOL.fieldOf("random_mirror").orElse(false).forGetter(config -> {
			return config.randomMirror;
		}), RegistryCodecs.homogeneousList(Registries.BLOCK).fieldOf("ignored_blocks").forGetter(config -> {
			return config.ignoredBlocks;
		}), Vec3i.offsetCodec(48).optionalFieldOf("offset", Vec3i.ZERO).forGetter(config -> {
			return config.offset;
		})).apply(builder, StructureFeatureConfiguration::new);
	});
}
<#-- @formatter:on -->
