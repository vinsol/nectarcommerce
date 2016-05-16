import React from "react";
import DismissableAlert from "./dismissable_alert";

export default class StackedAlerts extends React.Component {
  render() {
    const alerts = this.props.alerts.map( (alert, idx) => <DismissableAlert
                                                             message={alert.message}
                                                             key={idx}
                                                             index={idx}
                                                             dismiss={this.props.clear.bind(this, idx)}/>);
    return (
      <div>
        {alerts}
      </div>
    );
  }
}
