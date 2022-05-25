import React from 'react'
import {
	AttachmentProgressBarContainerClass,
	AttachmentProgressBarClass,
} from '../constants'

export const AttachmentProgressBar = ({progress}) => {
	return (
		<div className={AttachmentProgressBarContainerClass} >
			<span className={AttachmentProgressBarClass} style={{width: `${progress}%`}} />
		</div>
	)
};
