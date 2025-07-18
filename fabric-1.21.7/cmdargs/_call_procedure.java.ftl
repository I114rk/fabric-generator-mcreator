<#include "procedures.java.ftl">
.executes(arguments -> {
	ServerLevel world = arguments.getSource().getLevel();

	double x = arguments.getSource().getPosition().x();
	double y = arguments.getSource().getPosition().y();
	double z = arguments.getSource().getPosition().z();

	Entity entity = arguments.getSource().getEntity();

    Direction direction = Direction.DOWN;
    if (entity != null)
    	direction = entity.getDirection();

	<@procedureToCode name=procedure dependencies=dependencies/>
	return 0;
})