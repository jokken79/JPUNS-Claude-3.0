import React from 'react';

export interface IconBaseProps extends React.SVGProps<SVGSVGElement> {
  size?: number | string;
}

export type IconType = React.FC<IconBaseProps>;
