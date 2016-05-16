import React from "react";
import DismissableAlert from "./dismissable_alert";

export default class StackedAlerts extends React.Component {
  render() {
    const alerts = this.props.alerts.map( (alert, idx) => <DismissableAlert message={alert.message} key={idx} index={idx} clear={this.props.clear}/>);
    return (
      <div>
        {alerts}
      </div>
    );
  }
}
