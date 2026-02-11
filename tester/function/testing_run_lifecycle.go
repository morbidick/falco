package function

import (
	"github.com/ysugimoto/falco/interpreter"
	"github.com/ysugimoto/falco/interpreter/context"
	"github.com/ysugimoto/falco/interpreter/function/errors"
	"github.com/ysugimoto/falco/interpreter/value"
)

const Testing_run_lifecycle_Name = "testing.run_lifecycle"

func Testing_run_lifecycle_Validate(args []value.Value) error {
	if len(args) != 0 {
		return errors.ArgumentMustEmpty(Testing_run_lifecycle_Name, args)
	}
	return nil
}

func Testing_run_lifecycle(
	ctx *context.Context,
	i *interpreter.Interpreter,
	args ...value.Value,
) (value.Value, error) {

	if err := Testing_run_lifecycle_Validate(args); err != nil {
		return nil, errors.NewTestingError("%s", err.Error())
	}

	if err := i.ProcessTestLifecycle(); err != nil {
		return value.Null, errors.NewTestingError("%s", err.Error())
	}

	return &value.String{Value: i.TestingState.String()}, nil
}
