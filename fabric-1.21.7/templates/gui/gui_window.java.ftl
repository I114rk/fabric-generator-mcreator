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

package ${package}.client.gui;

<#assign mx = data.W - data.width>
<#assign my = data.H - data.height>

public class ${name}Screen extends AbstractContainerScreen<${name}Menu> {

	private final static HashMap<String, Object> guistate = ${name}Menu.guistate;

	private final Level world;
	private final int x, y, z;
	private final Player entity;

	<#list data.getComponentsOfType("TextField") as component>
		EditBox ${component.getName()};
	</#list>

	<#list data.getComponentsOfType("Checkbox") as component>
		Checkbox ${component.getName()};
	</#list>

	<#list data.getComponentsOfType("Button") as component>
		Button ${component.getName()};
	</#list>

	<#list data.getComponentsOfType("ImageButton") as component>
		ImageButton ${component.getName()};
	</#list>

	public ${name}Screen(${name}Menu container, Inventory inventory, Component text) {
		super(container, inventory, text);
		this.world = container.world;
		this.x = container.x;
		this.y = container.y;
		this.z = container.z;
		this.entity = container.entity;
		this.imageWidth = ${data.width};
		this.imageHeight = ${data.height};
	}

	<#if data.doesPauseGame>
	@Override public boolean isPauseScreen() {
		return true;
	}
	</#if>

	<#if data.renderBgLayer>
	private static final ResourceLocation texture = new ResourceLocation("${modid}:textures/screens/${registryname}.png" );
	</#if>

	@Override public void render(GuiGraphics guiGraphics, int mouseX, int mouseY, float partialTicks) {
		this.renderBackground(guiGraphics);
		super.render(guiGraphics, mouseX, mouseY, partialTicks);
		this.renderTooltip(guiGraphics, mouseX, mouseY);

		<#list data.getComponentsOfType("Tooltip") as component>
			<#assign x = (component.x - mx/2)?int>
			<#assign y = (component.y - my/2)?int>
			<#if hasProcedure(component.displayCondition)>
				if (<@procedureOBJToConditionCode component.displayCondition/>)
			</#if>
				if (mouseX > leftPos + ${x} && mouseX < leftPos + ${x + component.width} && mouseY > topPos + ${y} && mouseY < topPos + ${y + component.height})
					guiGraphics.renderTooltip(font, <#if hasProcedure(component.text)>Component.literal(<@procedureOBJToStringCode component.text/>)<#else>Component.translatable("gui.${modid}.${registryname}.${component.getName()}")</#if>, mouseX, mouseY);
		</#list>

		<#list data.components as component>
			<#if component.getClass().getSimpleName() == "TextField">
				${component.name}.render(guiGraphics, mouseX, mouseY, partialTicks);
			</#if>
		</#list>

		<#list data.getComponentsOfType("EntityModel") as component>
			<#assign followMouse = component.followMouseMovement>
			<#assign x = (component.x - mx/2)?int>
			<#assign y = (component.y - my/2)?int>
			if (<@procedureOBJToConditionCode component.entityModel/> instanceof LivingEntity livingEntity) {
				<#if hasProcedure(component.displayCondition)>
					if (<@procedureOBJToConditionCode component.displayCondition/>)
				</#if>
				<#if component.followMouseMovement>
					InventoryScreen.renderEntityInInventoryFollowsMouse(guiGraphics, this.leftPos + ${x + 11}, this.topPos + ${y + 21}, ${component.scale},
						${component.rotationX / 20.0}f + (float) Math.atan((this.leftPos + ${x + 11} - mouseX) / 40.0),
						(float) Math.atan((this.topPos + ${y + 21 - 50} - mouseY) / 40.0), livingEntity);
				<#else>
					InventoryScreen.renderEntityInInventory(guiGraphics, this.leftPos + ${x + 11}, this.topPos + ${y + 21}, ${component.scale},
						new Quaternionf().rotateX(${component.rotationX / 20.0}f), new Quaternionf(), livingEntity);
				</#if>
			}
		</#list>
	}

	@Override protected void renderBg(GuiGraphics guiGraphics, float partialTicks, int gx, int gy) {
		RenderSystem.setShaderColor(1, 1, 1, 1);
		RenderSystem.enableBlend();
		RenderSystem.defaultBlendFunc();

		<#if data.renderBgLayer>
			guiGraphics.blit(texture, this.leftPos, this.topPos, 0, 0, this.imageWidth, this.imageHeight, this.imageWidth, this.imageHeight);
		</#if>

		<#list data.components as component>
			<#if component.getClass().getSimpleName() == "Image">
				<#if hasProcedure(component.displayCondition)>if (<@procedureOBJToConditionCode component.displayCondition/>) {</#if>
					guiGraphics.blit(new ResourceLocation("${modid}:textures/screens/${component.image}"), this.leftPos + ${(component.x - mx/2)?int},
						this.topPos + ${(component.y - my/2)?int}, 0, 0,
						${component.getWidth(w.getWorkspace())}, ${component.getHeight(w.getWorkspace())},
						${component.getWidth(w.getWorkspace())}, ${component.getHeight(w.getWorkspace())});
				<#if hasProcedure(component.displayCondition)>}</#if>
			</#if>
		</#list>

		RenderSystem.disableBlend();
	}

	@Override public boolean keyPressed(int key, int b, int c) {
		if (key == 256) {
			this.minecraft.player.closeContainer();
			return true;
		}

		<#list data.components as component>
			<#if component.getClass().getSimpleName() == "TextField">
			if(${component.name}.isFocused())
				return ${component.name}.keyPressed(key, b, c);
			</#if>
		</#list>

		return super.keyPressed(key, b, c);
	}

	@Override public void containerTick() {
		super.containerTick();
		<#list data.components as component>
			<#if component.getClass().getSimpleName() == "TextField">
				${component.name}.tick();
			</#if>
		</#list>
	}

	@Override protected void renderLabels(GuiGraphics guiGraphics, int mouseX, int mouseY) {
		<#list data.components as component>
			<#if component.getClass().getSimpleName() == "Label">
				<#if hasProcedure(component.displayCondition)>
				if (<@procedureOBJToConditionCode component.displayCondition/>)
				</#if>
				guiGraphics.drawString(this.font,
				<#if hasProcedure(component.text)><@procedureOBJToStringCode component.text/><#else>Component.translatable("gui.${modid}.${registryname}.${component.getName()}")</#if>,
					${(component.x - mx / 2)?int}, ${(component.y - my / 2)?int}, ${component.color.getRGB()}, false);
			</#if>
		</#list>
	}

	@Override public void onClose() {
		super.onClose();
	}

	@Override public void init() {
		super.init();

		<#list data.getComponentsOfType("TextField") as component>
			${component.getName()} = new EditBox(this.font, this.leftPos + ${(component.x - mx/2)?int}, this.topPos + ${(component.y - my/2)?int},
			${component.width}, ${component.height}, Component.translatable("gui.${modid}.${registryname}.${component.getName()}"))
			<#if component.placeholder?has_content>
			{
				{
					setSuggestion(Component.translatable("gui.${modid}.${registryname}.${component.getName()}").getString());
				}

				@Override public void insertText(String text) {
					super.insertText(text);

					if (getValue().isEmpty())
						setSuggestion(Component.translatable("gui.${modid}.${registryname}.${component.getName()}").getString());
					else
						setSuggestion(null);
				}

				@Override public void moveCursorTo(int pos) {
					super.moveCursorTo(pos);

					if (getValue().isEmpty())
						setSuggestion(Component.translatable("gui.${modid}.${registryname}.${component.getName()}").getString());
					else
						setSuggestion(null);
				}
			}
			</#if>;
			${component.getName()}.setMaxLength(32767);

			guistate.put("text:${component.getName()}", ${component.getName()});
			this.addWidget(this.${component.getName()});
		</#list>

		<#assign btid = 0>
		<#list data.getComponentsOfType("Button") as component>
			<#if component.isUndecorated>
				${component.getName()} = new PlainTextButton(
					this.leftPos + ${component.gx(data.width)}, this.topPos + ${component.gy(data.height)},
					${component.width}, ${component.height},
					Component.translatable("gui.${modid}.${registryname}.${component.getName()}"),
					<@buttonOnClick component/>, this.font
				)<@buttonDisplayCondition component/>;
			<#else>
				${component.getName()} = Button.builder(Component.translatable("gui.${modid}.${registryname}.${component.getName()}"), <@buttonOnClick component/>)
					.bounds(this.leftPos + ${component.gx(data.width)}, this.topPos + ${component.gy(data.height)},
					${component.width}, ${component.height})
					<#if hasProcedure(component.displayCondition)>
						.build(builder -> new Button(builder)<@buttonDisplayCondition component/>);
					<#else>
						.build();
					</#if>
			</#if>

			guistate.put("button:${component.getName()}", ${component.getName()});
			this.addRenderableWidget(${component.getName()});

			<#assign btid +=1>
		</#list>

		<#list data.getComponentsOfType("ImageButton") as component>
			${component.getName()} = new ImageButton(
				this.leftPos + ${component.gx(data.width)}, this.topPos + ${component.gy(data.height)},
				${component.getWidth(w.getWorkspace())}, ${component.getHeight(w.getWorkspace())},
				0, 0, ${component.getHeight(w.getWorkspace())},
				new ResourceLocation("${modid}:textures/screens/atlas/${component.getName()}.png"),
				${component.getWidth(w.getWorkspace())},
				${component.getHeight(w.getWorkspace()) * 2},
				<@buttonOnClick component/>
			)<@buttonDisplayCondition component/>;

			guistate.put("button:${component.getName()}", ${component.getName()});
			this.addRenderableWidget(${component.getName()});

			<#assign btid +=1>
		</#list>

		<#list data.getComponentsOfType("Checkbox") as component>
			${component.getName()} = new Checkbox(this.leftPos + ${(component.x - mx/2)?int}, this.topPos + ${(component.y - my/2)?int},
					20, 20, Component.translatable("gui.${modid}.${registryname}.${component.getName()}"), <#if hasProcedure(component.isCheckedProcedure)>
				<@procedureOBJToConditionCode component.isCheckedProcedure/><#else>false</#if>);

			guistate.put("checkbox:${component.getName()}", ${component.getName()});
			this.addRenderableWidget(${component.getName()});
		</#list>
	}

}
<#macro buttonOnClick component>
e -> {
	<#if hasProcedure(component.onClick)>
		if (<@procedureOBJToConditionCode component.displayCondition/>) {
			ClientPlayNetworking.send(new ResourceLocation(${JavaModName}.MODID, "${name?lower_case}_button_${btid}"), new ${name}ButtonMessage(${btid}, x, y, z));
		}
	</#if>
}
</#macro>

<#macro buttonDisplayCondition component>
<#if hasProcedure(component.displayCondition)>
{
	@Override public void render(GuiGraphics guiGraphics, int gx, int gy, float ticks) {
		if (<@procedureOBJToConditionCode component.displayCondition/>)
			super.render(guiGraphics, gx, gy, ticks);
	}
}
</#if>
</#macro>
<#-- @formatter:on -->